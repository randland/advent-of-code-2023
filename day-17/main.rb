require "benchmark"
require "pry-byebug"
require "set"

def file(path) = File.read(File.join(__dir__, path))

def parse(data) = Grid.new(data.split("\n").map { |line| line.chars.map(&:to_i) })

class Grid
  attr_reader :cells
  def initialize(cells) = @cells = cells
  def [](r, c) = cells[r][c]
  def height = @height ||= cells.count
  def width = @width ||= cells.first.count
  def cover?(r, c) = (0...height).cover?(r) && (0...width).cover?(c)
end

MoveResult = Data.define(:dest, :weight)

def straight_line(grid, r, c, dr, dc, start, stop)
  weight = 0

  (1..stop).map do |i|
    r += dr
    c += dc
    next unless grid.cover?(r, c)

    weight += grid[r, c]
    next if i < start
    MoveResult.new(dest: [r, c], weight: weight)
  end.compact
end

GridNode = Data.define(:loc, :vert) do
  include Comparable
  def <=>(other) = [loc, vert] <=> [other.loc, other.vert]
  def r = loc.first
  def c = loc.last
  def inspect = "[#{r}, #{c}]#{vert ? "|" : "-"}"
end

Arc = Data.define(:node, :weight) do
  include Comparable
  def <=>(other) = weight <=> other.weight
  def inspect = "#{node.inspect} = #{weight}"
end

def neighbors(grid, node, start, stop)
  [-1, 1].flat_map do |dir|
    dr = node.vert ? dir : 0
    dc = node.vert ? 0 : dir
    straight_line(grid, node.r, node.c, dr, dc, start, stop).map do |move_result|
      Arc.new(node: GridNode.new(loc: move_result.dest, vert: !node.vert),
              weight: move_result.weight)
    end
  end
end

class ArcPriorityQueue
  attr_reader :arcs
  def initialize = @arcs = [nil]
  def any? = arcs.any?

  def <<(el)
    arcs << el
    bubble_up(arcs.size - 1)
  end

  def bubble_up(idx)
    parent_idx = idx / 2
    return if idx <= 1
    return if arcs[parent_idx] <= arcs[idx]

    exchange(idx, parent_idx)
    bubble_up(parent_idx)
  end

  def bubble_down(idx)
    child_idx = idx * 2
    return if child_idx > arcs.size - 1

    left, right = arcs[child_idx, 2]
    child_idx += 1 if right && right.weight < left.weight
    return if arcs[idx] <= arcs[child_idx]

    exchange(idx, child_idx)
    bubble_down(child_idx)
  end

  def exchange(a, b) 
    arcs[a], arcs[b] = arcs[b], arcs[a]
  end

  def pop
    exchange(1, arcs.size - 1)
    arcs.pop.tap { bubble_down(1) }
  end
end

def djikstra(grid, start_loc, dest, start, stop)
  visited = Set.new
  queue = ArcPriorityQueue.new

  queue << Arc.new(node: GridNode.new(loc: start_loc, vert: true), weight: 0)
  queue << Arc.new(node: GridNode.new(loc: start_loc, vert: false), weight: 0)
  dist = Hash.new { |h, idx| h[idx] = Float::INFINITY }

  while queue.any?
    arc = queue.pop
    return arc.weight if arc.node.loc == dest

    next if visited.include?(arc.node)
    visited << arc.node

    neighbors(grid, arc.node, start, stop).each do |neighbor|
      new_dist = arc.weight + neighbor.weight
      if new_dist < dist[neighbor.node]
        dist[neighbor.node] = new_dist
        queue << Arc.new(node: neighbor.node, weight: new_dist)
      end
    end
  end

  Float::INFINITY
end

def part1(data)
  djikstra(data, [0, 0], [data.height - 1, data.width - 1], 1, 3)
end

def part2(data)
  djikstra(data, [0, 0], [data.height - 1, data.width - 1], 4, 10)
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
