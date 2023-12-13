def file(path) = File.read(File.join(__dir__, path))

NUMS = {
  one: 1,
  two: 2,
  three: 3,
  four: 4,
  five: 5,
  six: 6,
  seven: 7,
  eight: 8,
  nine: 9
}.transform_keys(&:to_s).transform_values(&:to_s).freeze
INV_NUMS = NUMS.transform_keys(&:reverse).freeze

def parse(data) = data.split("\n")

def part1(data)
  data.map { |l| l.scan(/\d/) }.map do |nums|
    (nums.first + nums.last).to_i
  end.sum
end

def num_scan_regex(nums_def) = /(#{nums_def.keys.join("|")}|\d)/

def part2(data)
  data.map do |l|
    first = l.scan(num_scan_regex(NUMS)).first.first
    last = l.reverse.scan(num_scan_regex(INV_NUMS)).first.first
    ((NUMS[first] || first) + (INV_NUMS[last] || last)).to_i
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
