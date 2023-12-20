require "benchmark"
require "pry-byebug"
require "set"

def file(path) = File.read(File.join(__dir__, path))

DIRS = {
  ?R => [0, 1],
  ?D => [1, 0],
  ?L => [0, -1],
  ?U => [-1, 0]
}.freeze

DigDef = Data.define(:dir, :dist, :color)

def parse(data)
  data.split("\n").map do |line|
    line.split(" ").then do |dir, dist, color|
      DigDef.new(dir: dir, dist: dist.to_i, color: color[2..-2])
    end
  end
end

class DigMap
  attr_reader :vertices, :perimeter

  def initialize(dig_defs)
    @vertices = []

    populate_digs(dig_defs)
  end

  def populate_digs(dig_defs)
    r = 0
    c = 0
    @perimeter = 0
    @vertices = []

    dig_defs.each do |dig_def|
      vertices << [r, c]
      dr, dc = DIRS[dig_def.dir]
      r += dig_def.dist * dr
      c += dig_def.dist * dc
      @perimeter += dig_def.dist
    end

    @vertices << [0, 0]
  end

  def shoelace
    vertices.each_cons(2).
      map { |(r1, c1), (_r2, c2)| (c2 - c1) * r1 }.
      sum.abs
  end

  def area = shoelace + (perimeter / 2 + 1)
end

def part1(data)
  DigMap.new(data).area
end

def part2(data)
  new_data = data.map do |dig_def|
    DigDef.new(dir: DIRS.keys[dig_def.color[-1].to_i],
               dist: dig_def.color[0..-2].to_i(16),
               color: dig_def.color)
  end

  DigMap.new(new_data).area
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
