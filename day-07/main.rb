require "set"
require "pry"

def file(path) = File.read(File.join(__dir__, path))

def parse(data)
  data.split("\n").map do |line|
    line.split(" ").then { |hand, bet| [hand, bet.to_i] }
  end
end

class CamelHand
  include Comparable

  attr_reader :hand, :bet, :sort_order, :joker

  def initialize(hand, bet, sort_order, joker = false)
    @hand = hand
    @bet = bet
    @sort_order = sort_order
    @joker = joker
  end

  def grouped_cards
    @grouped_cards ||= Hash[
      @hand.chars.group_by(&:to_s).transform_values(&:count).sort_by(&:last).reverse
    ].tap do |results|
      if joker && results["J"] && results.count > 1
        top_card = results.keys.first != "J" ? results.keys.first : results.keys[1]
        results[top_card] += results["J"]
        results.delete("J")
      end
    end
  end

  def type_score = grouped_cards.values
  def hand_score = hand.chars.map { |c| sort_order.reverse.index(c) }
  def sort_key = [type_score, hand_score]
  def <=>(other) = sort_key <=> other.sort_key
end

def part1(data)
  hands = data.map { |hand, bet| CamelHand.new(hand, bet, "AKQJT98765432") }
  hands.sort.map.with_index { |h, i| h.bet * (i + 1) }.sum
end

def part2(data)
  hands = data.map { |hand, bet| CamelHand.new(hand, bet, "AKQT98765432J", true) }
  hands.sort.map.with_index { |h, i| h.bet * (i + 1) }.sum
end

EXAMPLE = parse file "example"
INPUT = parse file "input"

puts <<~END
##########
# Part 1 #
##########
Example: #{part1 EXAMPLE}
Solution: #{part1 INPUT}

##########
# Part 2 #
##########
Example: #{part2 EXAMPLE}
Solution: #{part2 INPUT}
END
__END__
