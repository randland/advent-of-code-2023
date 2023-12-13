require "set"
def file(path) = File.read(File.join(__dir__, path))

DIRS = {
  "|" => %i[n s],
  "-" => %i[e w],
  "L" => %i[n e],
  "J" => %i[n w],
  "7" => %i[s w],
  "F" => %i[s e],
  "." => %i[],
  "S" => %i[n s e w]
}

OPPOSED = {
  :n => :s,
  :s => :n,
  :e => :w,
  :w => :e
}

def parse(data)
  data.split("\n").map(&:chars)
end

# Returns the [r, c] of the start pipe
def start_location(data)
  data.each_with_index do |line, row|
    line.each_with_index do |char, col|
      return [row, col] if char == "S"
    end
  end
end

# The positions adjacent to the pipe at [r, c]
def neighbors(data, r, c) = pipe_dirs(data, r, c).map { |dir| neighbor(dir, r, c) }

# The position adjacent in dir direction from [r, c]
def neighbor(dir, r, c)
  case dir
  when :n then [r - 1, c]
  when :s then [r + 1, c]
  when :e then [r, c + 1]
  when :w then [r, c - 1]
  else raise "#{dir} is not a direction"
  end
end

# All directions that the pipe at [r, c] connect to
def pipe_dirs(data, r, c) = DIRS[pipe(data, r, c)]

# Pipe shape at [r, c]
def pipe(data, r, c) = data[r][c]

# Returns array of positions for the circular path
def path(data)
  start = start_location(data)
  # Grab the two neighbors of the start pipe and start two paths
  paths = neighbors(data, *start).select do |loc|
            neighbors(data, *loc).include?(start)
          end.map { |step_two| [start, step_two] }

  # Determine what the start pipe was
  start_pipe = DIRS.to_a.select do |shape, dirs|
                 dirs.map do |dir|
                   neighbor(dir, *start)
                 end.all? do |loc|
                   paths.map(&:last).include?(loc)
                 end
               end.first.first
  # Replace the value "S" with the correct pipe in the data
  data[start[0]][start[1]] = start_pipe

  # Until we reach the same point
  while paths.first.last != paths.last.last
    paths.each do |path|
      # Add the neighbor of the last position that was not the one before it
      path << neighbors(data, *path[-1])
              .reject { |n| n ==  path[-2] }
              .first
    end
  end

  # Join the paths into a loop with the start first
  paths[0] + paths[1][1..].reverse
end

# Returns cells that are inside the loop
def inner_cells(data)
  # Create a set of the path so we can search quick
  pipes = Set.new(path(data))
  # We know of nothing inside yet
  inside = []

  data.each_with_index do |line, row|
    # Start a counter for this row
    count = 0

    # Create a list of index and character for the line
    short_line = line.filter_map.with_index do |char, idx|
      # Ignore horizontal pipes that are in the loop
      [idx, char] unless char == "-" && pipes.include?([row, idx])
    end

    short_line.each_cons(2) do |(a_loc, a_pipe), (b_loc, b_pipe)|
      # A main pipe was found
      if pipes.include?([row, a_loc])
        # Increment the count if the pipe crosses vertically
        case a_pipe
        when "|" then count += 1
        when "F" then count += 1 if b_pipe == "J" # Not a u-turn
        when "L" then count += 1 if b_pipe == "7" # Not a u-turn
        end
      else
        # Add the cell if the count is odd
        inside << [row, a_loc] if count % 2 == 1
      end
    end
  end

  # Return all the inner positions
  inside
end

def part1(data)
  path(data.map(&:dup)).count / 2
end

def part2(data)
  inner_cells(data.map(&:dup)).count
end

EXAMPLE1 = parse file "example1".freeze
EXAMPLE2 = parse file "example2".freeze
EXAMPLE3 = parse file "example3".freeze
INPUT = parse file "input".freeze

# puts "Part 1 Example: #{part1 EXAMPLE1}"
puts "Part 1 Solution: #{part1 INPUT}"

puts "Part 2 Example: #{part2 EXAMPLE2}"
puts "Part 2 Example: #{part2 EXAMPLE3}"
puts "Part 2 Solution: #{part2 INPUT}"
