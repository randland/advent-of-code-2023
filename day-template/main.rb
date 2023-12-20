require "benchmark"
require "pry-byebug"
require "set"

def file(path) = File.read(File.join(__dir__, path))

def parse(data)
  data.split("\n")
end

def part1(data)
  data.inspect
end

def part2(data)
end

EXAMPLE = parse file "example"
INPUT = parse file "input"

puts "# Part 1 #"
puts "Example: #{part1 EXAMPLE}"
# puts "Solution: #{part1 INPUT}"
puts
puts "# Part 2 #"
# puts "Example: #{part2 EXAMPLE}"
# puts "Solution: #{part2 INPUT}"
