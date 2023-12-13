require "set"
def file(path) = File.read(File.join(__dir__, path))


def parse(data)
  data.split("\n\n").then do |sequence, maps|
    {
      seq: sequence.chars.map { |c| c == "L" ? 0 : 1 },
      maps: maps.split("\n").map do |line|
              line.scan(/[A-Z0-9]{3}/).then do |start, left, right|
                { start => [left, right] }
              end
      end.inject(:merge)
    }
  end
end

def part1(data)
  count = 0
  pos = "AAA"
  data[:seq].cycle do |move|
    return count if pos == "ZZZ"

    pos = data[:maps][pos][move]
    count += 1
  end
end

def part2(data)
  starting_points = data[:maps].keys.select { |k| k[2] == "A" }

  starting_points.map do |start|
    count = 0
    pos = start
    data[:seq].cycle do |move|
      break if pos[2] == "Z"

      pos = data[:maps][pos][move]
      count += 1
    end
    count
  end.inject(:lcm)
end

EXAMPLE1 = parse file "example1"
EXAMPLE2 = parse file "example2"
INPUT = parse file "input"

puts <<~END
##########
# Part 1 #
##########
Example: #{part1 EXAMPLE1}
Solution: #{part1 INPUT}

##########
# Part 2 #
##########
Example: #{part2 EXAMPLE2}
Solution: #{part2 INPUT}
END
__END__
