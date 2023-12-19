require "benchmark"
require "pry-byebug"
require "set"

def file(path) = File.read(File.join(__dir__, path))

# class Range
#   def remove(other)
#     # Process every value in the array
#     if other.kind_of?(Array) then
#       return [self] if other.empty?

#       # Remove each chunk individually
#       return other.map(&method(:remove)).inject do |a, b|
#         # Join the intersections of all removed bits
#         a.product(b).filter_map { |x, y| x.intersect(y) }
#       end
#     end

#     # Other covers nothing
#     return [self] if other.nil? || other.max < min || other.min > max

#     # Other covers everything
#     return [] if other.min <= min && other.max >= max

#     # Other covers start of range
#     return [other.max+1..max] if other.min <= min && other.max < max

#     # Other covers end of range
#     return [min..other.min-1] if other.min > min && other.max >= max

#     [min..other.min-1, other.max+1..max]
#   end
# end

class Hash
  def deep_dup
    transform_keys(&:dup)
  end
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

    combs = 0
    workflows[loc].flow.each do |step|
      old_min, old_max = ranges[step.var]
      case step.op
      when "<"
        if old_min < step.val
          new_ranges = ranges.dup
          new_ranges[step.var] = [old_min, [old_max, step.val - 1].min]
          combs += find_comb(step.dest, new_ranges)
        end

        if old_max >= step.val
          ranges[step.var] = [[old_min, step.val].max, old_max]
        else
          break
        end
      when ">"
        if old_max > step.val
          new_ranges = ranges.merge(step.var => [[old_min, step.val + 1].max, old_max])
          combs += find_comb(step.dest, new_ranges)
        end

        if old_min <= step.val
          ranges[step.var] = [old_min, [old_max, step.val].min]
        else
          break
        end
      end
    end

    combs += find_comb(workflows[loc].default, ranges.deep_dup)
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

class OptionSet
  attr_reader :ranges

  def initialize
    @ranges = {
      "x" => [1, 4000],
      "m" => [1, 4000],
      "a" => [1, 4000],
      "s" => [1, 4000]
    }
  end

  def restrict(var, op, val)
    case op
    when ">"
      ranges[var] = [[ranges[var].first, val].max, ranges[var].last]
    when "<"
      ranges[var] = [ranges[var].first, [ranges[var].last, val].min]
    end
  end

  def combinations
    ranges.values.map(&:count).inject(:*)
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
  data.find_comb("in", { "x" => [1, 4000], "m" => [1, 4000], "a" => [1, 4000], "s" => [1, 4000] })
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
