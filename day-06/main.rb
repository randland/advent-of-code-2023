require "set"
require "pry"

def file(path) = File.read(File.join(__dir__, path))

def parse(data) = data.split("\n").map { |line| line.scan(/\d+/).map(&:to_i) }.then { |a, b| a.zip b }

def win_count(time, to_beat) = time.times.select { |t| (time - t) * t > to_beat }

def part1(data) = data.map { |time, to_beat| win_count(time, to_beat) }.map(&:count).inject(:*)

def part2(data)
  time = data.map(&:first).map(&:to_s).join.to_i
  to_beat = data.map(&:last).map(&:to_s).join.to_i

  win_count(time, to_beat).count
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
