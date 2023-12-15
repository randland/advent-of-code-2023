require "pry"

def file(path) = File.read(File.join(__dir__, path))
def parse(data) = data.split("\n").map { |line| line.chars }

def score(data)
  data.each.with_index.sum do |line, idx|
    line.filter_map { |c| data.length - idx if c == "O" }.sum
  end
end

def roll(data)
  data.map(&:dup).tap do |tmp|
    loop do
      first_found = 0
      tmp.each_with_index do |line, r|
        next unless r > first_found

        line.each_with_index do |char, c|
          next unless char == "O" && tmp[r - 1][c] == "."

          first_found = r if first_found.zero?
          tmp[r - 1][c] = "O"
          tmp[r][c] = "."
        end
      end
      break if first_found == 0
    end
  end
end

def part1(data) = score(roll(data))

def rotate(data) = data.reverse.transpose
def spin(data) = 4.times.reduce(data) { |d| rotate(roll(d)) }

def part2(data)
  maps = {}
  idx, len = (1..).each do |idx|
               data = spin(data)
               prev = maps[data]
               break [idx, idx - prev] if prev
               maps[data] = idx
             end

  offset = idx - len
  remaining = (1_000_000_000 - idx) % len
  score(maps.invert[remaining + offset])
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
