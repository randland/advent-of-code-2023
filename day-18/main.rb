require "benchmark"
require "pry-byebug"
require "set"

def file(path) = File.read(File.join(__dir__, path))

DigDef = Data.define(:dir, :dist, :color)

def parse(data)
  data.split("\n").map { |line| line.split(" ").then { |dir, dist, color| DigDef.new(dir, dist, color) } }
end

def move(dir, r, c)
  case dir
  when ?R then [r, c + 1]
  when ?L then [r, c - 1]
  when ?U then [r - 1, c]
  when ?D then [r + 1, c]
  end
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
