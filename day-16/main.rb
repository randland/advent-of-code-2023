require "set"
require "pry"

def file(path) = File.read(File.join(__dir__, path))

def parse(data) = data

Laser = Data.define(:dir, :pos) do
  def step = Laser.new(dir, next_pos)

  def r = pos.first
  def c = pos.last

  def next_pos
    case dir
    when :n then [r - 1, c]
    when :s then [r + 1, c]
    when :e then [r, c + 1]
    when :w then [r, c - 1]
    end
  end
end

class LaserMap
  RunResult = Data.define(:num_energized, :exits)

  DEST_MAP = {
    ?|  => { n: %i[n],   s: %i[s],   e: %i[n s], w: %i[n s] },
    ?-  => { n: %i[e w], s: %i[e w], e: %i[e],   w: %i[w]   },
    ?/  => { n: %i[e],   s: %i[w],   e: %i[n],   w: %i[s]   },
    ?\\ => { n: %i[w],   s: %i[e],   e: %i[s],   w: %i[n]   },
    ?.  => { n: %i[n],   s: %i[s],   e: %i[e],   w: %i[w]   }
  }

  attr_reader :map

  def initialize(data)
    @map = data.split("\n").map(&:chars)
  end

  def rows = map.length
  def cols = map.first.length

  def sym_at(pos)
    return unless pos.none?(&:negative?)
    map.dig(pos.first, pos.last)
  end

  def step(laser)
    DEST_MAP[sym_at(laser.pos)][laser.dir].map { |dir| Laser.new(dir, laser.pos) }
  end

  def run_laser(dir, pos)
    lasers = [Laser.new(dir, pos)]
    energized = Hash.new { |h, v| h[v] = Set.new }
    exits = Set.new

    while lasers.any?
      next_step = lasers.first.step

      if sym_at(next_step.pos).nil?
        exits << next_step.pos
        next lasers.shift
      end

      if energized[next_step.pos].include?(next_step.dir)
        next lasers.shift
      else
        energized[next_step.pos] << next_step.dir
      end

      lasers[0] = step(next_step)
      lasers.flatten!
    end

    RunResult.new(energized.count, exits)
  end
end

def part1(data)
  LaserMap.new(data).run_laser(:e, [0, -1]).num_energized
end

def part2(data)
  map = LaserMap.new(data)
  r_count = map.rows
  c_count = map.cols

  start_args = (0...r_count).map { |r| [:e, [r, -1]] } +
               (0...r_count).map { |r| [:w, [r, c_count]] } +
               (0...c_count).map { |c| [:s, [-1, c]] } +
               (0...c_count).map { |c| [:n, [r_count, c]] }

  exits = Set.new

  start_args.map do |laser_args|
    next 0 if exits.include?(laser_args.last)
    results = map.run_laser(*laser_args)
    exits += results.exits
    results.num_energized
  end.max
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
