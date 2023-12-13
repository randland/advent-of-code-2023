require "set"
require "pry"

def file(path) = File.read(File.join(__dir__, path))

def parse(data)
  data.split("\n\n").map do |pattern|
    pattern.split("\n").map { |line| line.chars }
  end
end

def find_mirror_lines(pattern, max_diffs = 0)
  (1...pattern.length).select do |i|
    pattern[i-1].zip(pattern[i]).count { |a, b| a != b } <= max_diffs
  end
end

def find_mirror(pattern, diffs = 0)
  find_mirror_lines(pattern).find do |line|
    left = pattern[...line].reverse
    right = pattern[line..]
    pairs = left.length < right.length ? left.zip(right) : right.zip(left)
    pairs.map { |a, b| a.zip(b).count { |x, y| x != y } }.sum == diffs
  end || 0
end

def part1(data)
  data.map do |pattern|
    find_mirror(pattern.transpose, 0) + find_mirror(pattern, 0) * 100
  end.sum
end

def part2(data)
  data.map do |pattern|
    find_mirror(pattern.transpose, 1) + find_mirror(pattern, 1) * 100
  end.sum
end

EXAMPLE = parse file "example"
INPUT = parse file "input"

puts <<~END
##########
# Part 1 #
##########
Example: #{part1 EXAMPLE}
Solution: #{part1 INPUT}

##########
# Part 2 #
##########
Example: #{part2 EXAMPLE}
Solution: #{part2 INPUT}
END
__END__
