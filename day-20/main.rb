require "benchmark"
require "pry-byebug"
require "set"

def file(path) = File.read(File.join(__dir__, path))

Pulse = Data.define(:src, :dest, :val)

class ElfModule
  attr_reader :name, :dests, :state
  def initialize(name, dests, state = false)
    @name = name
    @dests = dests
    @state = state
  end

  def emit(val)
    dests.map do |dest|
      Pulse.new(src: name, dest: dest, val: val)
    end
  end

  def state_val = state
end

class FlipFlop < ElfModule
  def pulse(src, val)
    return [] if val
    @state = !state
    emit(state)
  end
end

class Conjunction < ElfModule
  attr_reader :inputs
  def initialize(name, dests, state = false)
    super
    @inputs = {}
  end

  def set_srcs(srcs) = srcs.each { |src| inputs[src] ||= false }

  def pulse(src, val)
    @inputs[src] = val
    @state = !@inputs.values.all?
    emit(state)
  end
end

class Broadcaster < ElfModule
  def pulse(src, val) = emit(val)
end

def parse(data)
  defs = data.split("\n").map do |line|
    line.split(" -> ").then { |name, dests| [name, dests.split(", ")] }
  end

  defs.inject({}) do |acc, (name, dests)|
    name_tail = name[1..]
    case name[0]
    when ?%
      acc.merge(name_tail => FlipFlop.new(name_tail, dests))
    when ?&
      srcs = defs
             .select { |name, val| val.include?(name_tail) }
             .map { |name, val| name.gsub(/[%&]/, "") }

      acc.merge(name_tail => Conjunction.new(name_tail, dests).tap { |conj| conj.set_srcs(srcs) })
    else
      acc.merge(name => Broadcaster.new(name, dests))
    end
  end
end

def part1(data)
  queue = []
  high = 0
  low = 0

  1000.times do
    queue << Pulse.new(src: "button", dest: "broadcaster", val: false)

    while queue.any?
      pulse = queue.shift
      pulse.val ? (high += 1) : (low += 1)
      next unless dest = data[pulse.dest]
      queue += dest.pulse(pulse.src, pulse.val)
    end
  end

  high * low
end

def find_loops(data)
  queue = []
  rx_in = data.select { |k, v| v.dests.include?("rx") }.keys.first
  outputs = data.select { |k, v| v.dests.include?(rx_in) }.keys
  loop_prevs = {}
  loop_runs = {}

  (1..).each do |run|
    queue << Pulse.new(src: "button", dest: "broadcaster", val: false)
    done = false

    while queue.any?
      pulse = queue.shift
      next unless dest = data[pulse.dest]
      queue += dest.pulse(pulse.src, pulse.val)

      if dest.name == rx_in && pulse.val
        if loop_runs[pulse.src].nil?
          if loop_prevs[pulse.src]
            loop_runs[pulse.src] = run - loop_prevs[pulse.src]
            if loop_runs.count == outputs.count
              return loop_runs
            end
          else
            loop_prevs[pulse.src] = run
          end
        end
      end
    end
  end
end

def part2(data)
  runs = find_loops(data)
  runs.values.inject(:lcm)
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
