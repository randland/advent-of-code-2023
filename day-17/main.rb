require "benchmark"
require "pry-byebug"
require "set"

def file(path) = File.read(File.join(__dir__, path))

def parse(data)
  data.split("\n").map { |line| line.chars.map(&:to_i) }
end

class LavaVert
  attr_reader :loc
  attr_accessor :dist, :prev, :val, :rows, :cols

  def initialize(map, loc)
    @loc = loc
    @dist = Float::INFINITY
    @rows = map.length
    @cols = map.first.length
    @val = map[loc.first][loc.last]
  end

  def row = loc.first
  def col = loc.last

  def neighbor_locs
    [
      [row - 1, col],
      [row + 1, col],
      [row, col - 1],
      [row, col + 1]
    ].reject { |r, c| r < 0 || r >= rows || c < 0 || c >= cols }
  end

  def inspect
    "(#{loc.join(", ")}) => #{dist}"
  end

  def to_s = inspect
end

def djikstra(map, start)
  untested = Set.new
  verts = Set.new
  map.each_with_index do |row, r_idx|
    row.each_with_index do |val, c_idx|
      vert = LavaVert.new(map, [r_idx, c_idx])
      untested << vert
      verts << vert
    end
  end

  start = verts.find { |lv| lv.loc == start }
  start.dist = map[start.loc.first][start.loc.last]

  while vert = untested.min_by(&:dist)
    untested.delete vert

    vert.neighbor_locs.each do |n_loc|
      next if n_loc == vert.prev
      neighbor = verts.find { |lv| lv.loc == n_loc }
      n_dist = vert.dist + neighbor.val
      next if n_dist >= neighbor.dist
      last_1 = vert.prev
      last_2 = last_1&.prev

      locs = [neighbor, vert, last_1, last_2]
      if locs.none?(&:nil?)
        locs = locs.map(&:loc).transpose
        next if locs.any? { |dim| dim.all? { |n| n == dim&.first }}
      end

      neighbor.prev = vert
      neighbor.dist = n_dist
      untested << neighbor
    end
  end

  verts
end

def part1(data)
  result = djikstra(data, [0, 0])
  vert = result.find { |lv| lv.loc == [data.length - 1, data.first.length - 1] }

  verts = [vert]
  while vert = vert.prev
    verts << vert
  end

#   binding.pry
#   verts.map do |v|
#     { vert.loc => vert.dist }
#   end.inject(:merge)

  data.each_with_index do |row, r_idx|
    row.each_with_index do |val, c_idx|
      if verts.find { |lv| lv.loc == [r_idx, c_idx] }
        print "#"
      else
        print val
      end
    end
    puts
  end
end

def part2(data)
end

EXAMPLE = parse file "example"
INPUT = parse file "input"

puts "# Part 1 #"
puts "Example: #{part1 EXAMPLE}"
# puts "Solution: #{part1 INPUT}"
puts
puts "# Part 2 #"
# puts "Example: #{part2 EXAMPLE}"
# puts "Solution: #{part2 INPUT}"
