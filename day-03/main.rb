require "set"
def file(path) = File.read(File.join(__dir__, path))

# Holds horizontal and vertical ranges, as well as the original model value
class ModelNum
  attr_reader :r_range, :c_range, :value

  def initialize(pos, str)
    @value = str.to_i
    @r_range = (pos[0] - 1)..(pos[0] + 1)
    @c_range = (pos[1] - 1)..(pos[1] + str.length)
  end

  # Does a model number's surrounding box cover a position
  def cover?(pos) = r_range.cover?(pos[0]) && c_range.cover?(pos[1])
end

# Returns an array of arrays that contain [position, match]
def find_matches(str, row, pattern)
  enum = str.enum_for(:scan, pattern)
  positions = enum.map { Regexp.last_match.begin(0) }.map { |n| [row, n] }
  positions.zip(enum.to_a)
end

# Find all the model numbers and create ModelNum objects from them
def find_nums(str, row) = find_matches(str, row, /\d+/).map { |pos, match| ModelNum.new(pos, match) }
# Find all symbol positions
def find_symbols(str, row) = Hash[find_matches(str, row, /[^\d\.]/)]

def parse(data)
  lines = data.split("\n")
  {
    nums: lines.map.with_index { |line, r_idx| find_nums(line, r_idx) }.flatten,
    symbols: lines.map.with_index { |line, r_idx| find_symbols(line, r_idx) }.inject(:merge)
  }
end

# Gather any model numbers that cover any symbols and add their values together
def part1(data)
  data[:nums].select { |num| data[:symbols].keys.any?(&num.method(:cover?)) }.map(&:value).sum
end

def part2(data)
  # Positions of all the gears
  gears = data[:symbols].select { |_, val| val == "*" }.map(&:first)

  # Gather the products of any model numbers next to gears and then add them
  gears.map do |gear|
    # Count the number of neighboring numbers
    matches = data[:nums].select { |num| num.cover?(gear) }
    # Only consider cases where there are exactly two neigbors
    next 0 unless matches.count == 2

    # Multiply the model numbers together
    matches.map(&:value).inject(:*)
  end.sum
end

EXAMPLE = parse file "example"
INPUT = parse file "input"

puts "-- Part 1 --"
puts "Example: #{part1 EXAMPLE}"
puts "Solution: #{part1 INPUT}"
puts
puts "-- Part 2 --"
puts "Example: #{part2 EXAMPLE}"
puts "Solution: #{part2 INPUT}"
