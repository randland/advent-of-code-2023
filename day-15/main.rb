require "set"
require "pry"

def file(path) = File.read(File.join(__dir__, path))

def parse(data) = data.split("\n").join.split(",")

def hash(str) = str.chars.reduce(0) { |score, char| (((score + char.ord) * 17) % 256) }

def part1(data) = data.map(&method(:hash)).sum

def part2(data)
  boxes = {}

  data.each do |map|
    str, op, val = map.match(/([a-z]*)([-=])(\d*)$/).captures
    val = val == "" ? nil : val.to_i
    loc = hash(str)

    boxes[loc] ||= {}

    if op == "-"
      boxes[loc].delete(str)
    else
      boxes[loc][str] = val
    end
  end

  boxes.to_a.flat_map do |key, vals|
    vals.flat_map.with_index do |val, idx|
      (key + 1) * (idx + 1) * val.last
    end
  end.sum
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
