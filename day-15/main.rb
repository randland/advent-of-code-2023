require "set"
require "pry"

def file(path) = File.read(File.join(__dir__, path))

def parse(data) = data.split("\n").join.split(",")

def hash(str) = str.chars.reduce(0) { |val, char| (((val + char.ord) * 17) % 256) }

def part1(data) = data.map(&method(:hash)).sum

def populate(data)
  boxes = {}

  data.each do |map|
    label, op, val = map.match(/([a-z]*)([-=])(\d*)$/).captures
    val = val == "" ? nil : val.to_i
    loc = hash(label)

    boxes[loc] ||= {}

    op == "-" ? boxes[loc].delete(label) : boxes[loc][label] = val
  end

  boxes
end

def score(boxes)
  boxes.to_a.flat_map do |key, vals|
    vals.map.with_index do |val, idx|
      (key + 1) * (idx + 1) * val.last
    end
  end.sum
end

def part2(data)
  score(populate(data))
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
