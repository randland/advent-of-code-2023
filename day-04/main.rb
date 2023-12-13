require "set"
def file(path) = File.read(File.join(__dir__, path))

def parse(data)
  data.split("\n").map do |line|
    line.split(":")[1].split("|").map do |nums|
      nums.scan(/\d+/).map(&:to_i)
    end
  end
end

def part1(data)
  data.map do |winners, picks|
    (2 ** ((winners & picks).count - 1)).to_i
  end.sum
end

def part2(data)
  cards = Array.new(data.count) { 1 }
  data.each_with_index do |(winners, picks), idx|
    (winners & picks).count.times do |offset|
      cards[1 + idx + offset] += cards[idx]
    end
  end
  cards.sum
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
