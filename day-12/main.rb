require "set"
def file(path) = File.read(File.join(__dir__, path))

SpringDef = Data.define(:springs, :counts)

def parse(data)
  data.split("\n").map do |line|
    line.split(" ").then do |springs, counts|
      SpringDef.new(springs, counts.split(",").map(&:to_i))
    end
  end
end

RUN_MEMO = {}

def solve(str, run_count, counts)
  memo_key = [str, run_count, counts]
  return RUN_MEMO[memo_key] if RUN_MEMO[memo_key]

  if str.empty?
    # Ends on a fixed pipe
    if counts.empty? && run_count.zero?
      RUN_MEMO[memo_key] = 1
      return 1
    end

    # Ends on a broken pipe
    if counts.length == 1 && run_count == counts.first
      RUN_MEMO[memo_key] = 1
      return 1
    end

    # Invalid
    RUN_MEMO[memo_key] = 0
    return 0
  end

  avail = str.chars.count { |c| c != "." }
  needed = counts.sum
  if avail + run_count < needed
    RUN_MEMO[memo_key] = 0
    return 0
  end

  head = str[0]
  tail = str[1..]
  result = 0

  case head
  when "."
    if run_count.positive?
      # Ran out of room for run
      if run_count != counts.first
        RUN_MEMO[memo_key] = 0
        return 0
      end

      # Run was correct length
      result += solve(tail, 0, counts[1..])
    else
      # Nothing to see here
      result += solve(tail, 0, counts)
    end
  when "?"
    # In a run
    if run_count.positive?
      # Hit our count
      if run_count == counts.first
        # Add a fixed pipe
        result += solve(tail, 0, counts[1..])
      else
        # Add another broken pipe
        result += solve(tail, run_count + 1, counts)
      end
    else
      # Start a new run
      result += solve(tail, 1, counts)
      # Add another fixed pipe
      result += solve(tail, 0, counts)
    end
  when "#"
    # Add a broken pipe and see if we are still valid
    result += solve(tail, run_count + 1, counts)
  end

  RUN_MEMO[memo_key] = result
  result
end

def part1(data)
  data
    .map { |sd| solve(sd.springs, 0, sd.counts) }
    .sum
end

def part2(data)
  data
    .map { |sd| SpringDef.new(([sd.springs] * 5).join("?"), sd.counts * 5) }
    .map { |sd| solve(sd.springs, 0, sd.counts) }
    .sum
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
