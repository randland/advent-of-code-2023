require "set"
require "pry"

def file(path) = File.read(File.join(__dir__, path))

def parse(data) = data.split("\n").map(&:chars)

MIRRORS = {
  ?| => { n: %i[n], s: %i[s], e: %i[n s], w: %i[n s] },
  ?- => { n: %i[e w], s: %i[e w], e: %i[e], w: %i[w] },
  ?/ => { n: %i[e], s: %i[w], e: %i[n], w: %i[s] },
  ?\\ => { n: %i[w], s: %i[e], e: %i[s], w: %i[n] },
  ?. => { n: %i[n], s: %i[s], e: %i[e], w: %i[w] }
}

def offset(dir, r, c)
  case dir
  when :n then [r - 1, c]
  when :s then [r + 1, c]
  when :e then [r, c + 1]
  when :w then [r, c - 1]
  end
end

def move(laser) = Laser.new(offset(laser.dir, *laser.pos), laser.dir)
def mirror_at(data, laser) = data[laser.pos.first][laser.pos.last]

def split(laser, mirror)
  MIRRORS[mirror][laser.dir].map do |dir|
    Laser.new(laser.pos, dir)
  end
end

class Laser
  attr_accessor :pos, :dir
  def initialize(pos, dir)
    @pos = pos
    @dir = dir
  end

  def inspect
    "#{dir}@(#{pos.first}, #{pos.last})"
  end
end

def score(data, start_laser)
  mirrors = Set.new
  laser_counts = {}
  lasers = [start_laser]

  while lasers.any?
    next_step = move(lasers.first)
    next_pos = next_step.pos

    if next_pos.first < 0 || next_pos.first >= data.length ||
        next_pos.last < 0 || next_pos.last >= data.first.length
      lasers.shift
    else
      mirror = mirror_at(data, next_step)
      if mirror == "."
        laser_counts[next_step.pos] ||= Set.new
        if laser_counts[next_step.pos].include?(next_step.dir)
          lasers.shift
        else
          laser_counts[next_step.pos] << next_step.dir
          lasers[0] = next_step
        end
      else
        mirrors << next_step.pos
        lasers[0] = split(next_step, mirror)
      end
    end
    lasers.flatten!
  end

  laser_counts.count + mirrors.count
end

def part1(data)
  score(data, Laser.new([0, -1], :e))
end

def part2(data)
  r_count = data.length
  c_count = data.first.length

  start_lasers = (0...r_count).map { |r| [[r, -1], :e] } +
                 (0...r_count).map { |r| [[r, c_count], :w] } +
                 (0...c_count).map { |c| [[-1, c], :s] } +
                 (0...c_count).map { |c| [[r_count, c], :n] }

  start_lasers.map { |l| score(data, Laser.new(*l)) }.max
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
