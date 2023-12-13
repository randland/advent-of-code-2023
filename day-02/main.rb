def file(path) = File.read(File.join(__dir__, path))

MAX = {
  red: 12,
  green: 13,
  blue: 14
}

def parse(data)
  data.split("\n").map do |line|
    matches = line.match(/Game (?<game>\d+): (?<draws>.*)$/)

    { matches[:game].to_i => parse_draws(matches[:draws]) }
  end.compact.inject(:merge)
end

def parse_draws(game)
  game.split(";").map do |draw|
    draw.split(",").map do |num_color|
      num_color.split(" ").then do |num, color|
        {color => num.to_i}
      end
    end.inject(:merge)
  end
end

def part1(data)
  data.reject do |game, draws|
    draws.any? do |draw|
      draw.any? do |color, val|
        MAX[color.to_sym] < val
      end
    end
  end.keys.sum
end

def part2(data)
  data.values.map do |draws|
    max_vals = {red: 0, green: 0, blue: 0}

    draws.each do |draw|
      draw.each do |color, val|
        max_vals[color.to_sym] = val if max_vals[color.to_sym] < val
      end
    end

    max_vals.values.inject(:*)
  end.sum
end

EXAMPLE1 = parse file "example1"
EXAMPLE2 = parse file "example2"
INPUT = parse file "input"

puts "-- Part 1 --"
puts "Example: #{part1 EXAMPLE1}"
puts "Solution: #{part1 INPUT}"
puts
puts "-- Part 2 --"
puts "Example: #{part2 EXAMPLE2}"
puts "Solution: #{part2 INPUT}"
