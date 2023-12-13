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

puts <<~END
##########
# Part 1 #
##########
Example: #{part1 EXAMPLE}
END
__END__
Solution: #{part1 INPUT}

##########
# Part 2 #
##########
Example: #{part2 EXAMPLE}
Solution: #{part2 INPUT}
