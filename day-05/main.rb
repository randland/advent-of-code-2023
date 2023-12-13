require "set"
require "pry"

def file(path) = File.read(File.join(__dir__, path))

class Range
  include Comparable
  def <=>(other)
    min <=> other.min
  end

  def intersect(other)
    return nil if max < other.min || min > other.max

    [min, other.min].max..[max, other.max].min
  end

  def offset(n)
    self.min+n..self.max+n
  end

  def remove(other)
    # Process every value in the array
    if other.kind_of?(Array) then
      return [self] if other.empty?

      # Remove each chunk individually
      return other.map(&method(:remove)).inject do |a, b|
        # Join the intersections of all removed bits
        a.product(b).filter_map { |x, y| x.intersect(y) }
      end
    end

    # Other covers nothing
    return [self] if other.nil? || other.max < min || other.min > max

    # Other covers everything
    return [] if other.min <= min && other.max >= max

    # Other covers start of range
    return [other.max+1..max] if other.min <= min && other.max < max

    # Other covers end of range
    return [min..other.min-1] if other.min > min && other.max >= max

    [min..other.min-1, other.max+1..max]
  end
end

Almanac = Data.define(:seeds, :sections)
AlmanacRange = Data.define(:src_range, :dest_range, :offset)

def parse(data)
  data.split("\n\n").then do |sections|
    Almanac.new(
      seeds: sections[0].split(":")[1].split(" ").reject(&:empty?).map(&:to_i),
      sections: sections[1..].map do |section|
        section.split(":")[1].split("\n").filter_map do |line|
          next if line.empty?

          line.split(" ").reject(&:empty?).map(&:to_i).then do |dest, src, count|
            AlmanacRange.new((src...src+count), (dest...dest+count), dest - src)
          end
        end
      end
    )
  end
end

def part1(data)
  data.sections.inject(data.seeds.dup) do |seeds, section|
    seeds.map do |n|
      a_range = section.find { |ar| ar.src_range.cover?(n) }
      n + (a_range&.offset || 0)
    end
  end.min
end

def remap_range(src_range, ar)
  isec = src_range.intersect(ar.src_range)
  return [src_range, nil] unless isec

  [src_range.remove(isec), isec.offset(ar.offset)]
end

def remap_section(seeds, section)
  result = seeds.dup

  new_ranges = []

  section.each do |ar|
    result.each_with_index do |range, idx|
      isec = range.intersect(ar.src_range)
      next unless isec

      old_ranges, remapped = remap_range(range, ar)
      result[idx] = old_ranges
      new_ranges << [remapped].flatten
    end
    result.flatten!
  end

  [result + new_ranges].flatten
end

def part2(data)
  seeds_ranges = data.seeds.each_slice(2).map { |start, len| (start...start+len) }

  data.sections.each do |section|
    seeds_ranges = remap_section(seeds_ranges, section)
  end

  seeds_ranges.map(&:min).min
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
