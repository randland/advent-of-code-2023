require "set"
def file(path) = File.read(File.join(__dir__, path))

def parse(data)
  data.split("\n").map { |line| line.split(" ").map(&:to_i) }
end

def next_val(list)
  [list].tap do |lists|
    until lists.last.all?(&:zero?) do
      lists << lists.last.each_cons(2).map { |a, b| b - a }
    end
  end.map(&:last).sum
end

def part1(data)
  data.map(&method(:next_val)).sum
end

def part2(data)
  data.map(&:reverse).map(&method(:next_val)).sum
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
