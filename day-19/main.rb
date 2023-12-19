require "benchmark"
require "pry-byebug"
require "set"

def file(path) = File.read(File.join(__dir__, path))

class Hash
  def deep_dup = transform_keys(&:dup)
end

class WorkflowData
  attr_reader :workflows, :parts

  def initialize(workflows:, parts:)
    @workflows = workflows
    @parts = parts
  end

  def find_comb(loc, ranges)
    return 0 if loc == "R"
    return ranges.values.map { |a, b| b - a + 1 }.inject(:*) if loc == "A"

    count = 0
    workflows[loc].flow.each do |step|
      old_min, old_max = ranges[step.var]
      case step.op
      when "<"
        sub_ranges = ranges.merge(step.var => [old_min, step.val - 1])
        count += find_comb(step.dest, sub_ranges) if old_min < step.val
        ranges[step.var] = [step.val, old_max] if old_max >= step.val
      when ">"
        sub_ranges = ranges.merge(step.var => [step.val + 1, old_max])
        count += find_comb(step.dest, sub_ranges) if old_max > step.val
        ranges[step.var] = [old_min, step.val] if old_min <= step.val
      end
    end

    count + find_comb(workflows[loc].default, ranges.deep_dup)
  end
end

class Step
  attr_reader :var, :op, :val, :dest

  def initialize(var, op, val, dest)
    @var = var
    @op = op
    @val = val
    @dest = dest
  end

  def apply_to(part) = part[var].send(op, val) ? dest : nil
  def inspect = "#{var} #{op} #{val} => #{dest}"
end

class Workflow
  attr_reader :name, :flow, :default

  def initialize(line)
    @name, flow, @default = line.match(/([a-z]+)\{([^}]+),([a-zAR]+)\}/).captures
    @flow = flow.split(",").map do |flow_def|
      var, op, val, dest = flow_def.match(/([xmas])([<>])(\d+):([ARa-z]+)/).captures
      Step.new(var, op, val.to_i, dest)
    end
  end

  def process(part)
    flow.each do |step|
      dest = step.apply_to(part)
      return dest if dest
    end

    default
  end
end

def parse(data)
  data.split("\n\n").then do |workflows, parts|
    flows = workflows.split("\n").map(&Workflow.method(:new))
    WorkflowData.new(
      workflows: flows.reduce({}) { |acc, flow| acc.merge(flow.name => flow) },
      parts: parts.split("\n").map { |part_str| (eval part_str.gsub("=", ":")).transform_keys(&:to_s) }
    )
  end
end

def part1(data)
  accepted = Set.new
  rejected = Set.new

  data.parts.each do |part|
    loc = "in"

    until %w[A R].include?(loc)
      loc = data.workflows[loc].process(part)
    end

    loc == "A" ? accepted << part : rejected << part
  end

  accepted.map(&:values).map(&:sum).sum
end

def part2(data)
  data.find_comb(
    "in",
    {
      "x" => [1, 4000],
      "m" => [1, 4000],
      "a" => [1, 4000],
      "s" => [1, 4000]
    }
  )
end

EXAMPLE = parse file "example"
INPUT = parse file "input"

puts "# Part 1 #"
puts "Example: #{part1 EXAMPLE}"
puts "Solution: #{part1 INPUT}"
puts
puts "# Part 2 #"
puts "Example: #{part2 EXAMPLE}"
puts "Solution: #{part2 INPUT}"
