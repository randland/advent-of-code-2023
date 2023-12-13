require "set"
def file(path) = File.read(File.join(__dir__, path))


def parse(data)
  data.split("\n").map { |line| line.chars }
end

def find_galaxies(expansion, map)
  empty_r = map.filter_map.with_index do |line, idx|
    idx if line.none? { |c| c == "#" }
  end

  empty_c = map.transpose.filter_map.with_index do |line, idx|
    idx if line.none? { |c| c == "#" }
  end

  [].tap do |galaxies|
    map.each_with_index do |line, row|
      line.each_with_index do |char, col|
        next unless char == "#"

        galaxies << [
          row + (empty_r.count { |r| r < row } * (expansion - 1)),
          col + (empty_c.count { |c| c < col } * (expansion - 1))
        ]
      end
    end
  end
end

def manhattan(a, b)
  (a[0] - b[0]).abs + (a[1] - b[1]).abs
end

def part1(data)
  find_galaxies(2, data)
    .combination(2)
    .map { |a, b| manhattan(a, b) }
    .sum
end

def part2(data)
  find_galaxies(1_000_000, data)
    .combination(2)
    .map { |a, b| manhattan(a, b) }
    .sum
end

EXAMPLE = parse file "example"
INPUT = parse file "input"

# puts "-- Part 1 --"
puts "Example: #{part1 EXAMPLE}"
puts "Solution: #{part1 INPUT}"
# puts
# puts "-- Part 2 --"
puts "Example: #{part2 EXAMPLE}"
puts "Solution: #{part2 INPUT}"
