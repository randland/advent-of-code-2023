require "benchmark"
require "pry-byebug"
require "set"

def file(path) = File.read(File.join(__dir__, path))

def find_start(grid)
  grid.size.times do |r|
    grid.first.size.times do |c|
      return [r, c] if grid[r][c] == "S"
    end
  end
end

def parse(data)
  grid = data.split("\n").map(&:chars)
  start = find_start(grid)
  grid[start.first][start.last] = "."

  [grid, start]
end

WalkDist = Data.define(:steps, :loc) do
  include Comparable
  def <=>(other) = steps <=> other.steps
end

class PriorityQueue
  attr_reader :elements
  def initialize = @elements = [nil]
  def any? = elements.any?

  def <<(el)
    elements << el
    bubble_up(elements.size - 1)
  end

  def bubble_up(idx)
    parent_idx = idx / 2
    return if idx <= 1
    return if elements[parent_idx] <= elements[idx]

    exchange(idx, parent_idx)
    bubble_up(parent_idx)
  end

  def bubble_down(idx)
    child_idx = idx * 2
    return if child_idx > elements.size - 1

    left, right = elements[child_idx, 2]
    child_idx += 1 if right && right < left
    return if elements[idx] <= elements[child_idx]

    exchange(idx, child_idx)
    bubble_down(child_idx)
  end

  def exchange(a, b) 
    elements[a], elements[b] = elements[b], elements[a]
  end

  def pop
    exchange(1, elements.size - 1)
    elements.pop.tap { bubble_down(1) }
  end
end

def neighbors(grid, loc)
  [[0, 1], [0, -1], [1, 0], [-1, 0]].map do |dr, dc|
    new_loc = [loc, [dr, dc]].transpose.map(&:sum)
    next unless (0...grid.size).cover?(new_loc[0]) &&
                (0...grid.first.size).cover?(new_loc[1])
    next if grid[new_loc[0]][new_loc[1]] == "#"
    new_loc
  end.compact
end

def djikstra(grid, start_loc, steps)
  visited = Set.new
  queue = PriorityQueue.new
  queue << WalkDist.new(steps: 0, loc: start_loc)
  dist = Hash.new { |h, idx| h[idx] = Float::INFINITY }
  dist[start_loc] = 0

  while queue.any?
    walk_dist = queue.pop

    next if visited.include?(walk_dist.loc)
    visited << walk_dist.loc

    neighbors(grid, walk_dist.loc).each do |neighbor|
      new_dist = walk_dist.steps + 1
      if new_dist < dist[neighbor]
        dist[neighbor] = new_dist
        queue << WalkDist.new(steps: new_dist, loc: neighbor) if new_dist <= steps
      end
    end
  end

  dist
end

def part1(data, steps)
  djikstra(*data, steps).select { |k, v| v % 2 == steps % 2 }.count
end

def part2(data)
end

EXAMPLE = parse file "example"
INPUT = parse file "input"

puts "# Part 1 #"
puts "Example: #{part1 EXAMPLE, 6}"
puts "Solution: #{part1 INPUT, 64}"
puts
puts "# Part 2 #"
# puts "Example: #{part2 EXAMPLE}"
# puts "Solution: #{part2 INPUT}"
