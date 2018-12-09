require "benchmark"

@[AlwaysInline]
def assert(condition)
  raise("assertion failed") unless condition
end

def parse(input : String) : Tuple(Int32, UInt64)
  m = /^(\d+) players; last marble is worth (\d+) points/.match(input)
  raise "parse error" if m.nil? || m.size != 3
  Tuple.new(m[1].to_i, m[2].to_u64)
end

def pp_ring(ring : Deque(UInt64)) : Nil
  0.upto(ring.size - 1).each do |idx|
    printf " %d ", ring[idx]
  end
  printf "\n"
end

class Game
  property players : Iterator(Int32)
  property scores : Hash(Int32, UInt64)
  property marble_max : UInt64
  property ring : Deque(UInt64)

  def initialize(num_players : Int32, @marble_max)
    @ring = Deque(UInt64).new
    @scores = Hash(Int32, UInt64).new(0)
    @players = num_players.times.each.cycle
  end

  def play
    ring.push(0u64)
    1u64.upto(@marble_max).each do |marble|
      if (marble % 23) == 0
        ring.rotate!(-7)
        @scores[@players.first] += marble + ring.shift
      else
        ring.rotate!(2)
        ring.unshift(marble)
      end
    end
  end

  def winner : Tuple(Int32, UInt64)
    @scores.max_by { |p, s| s }
  end
end

def part1(input : String) : UInt64
  players, last_worth = parse(input)

  game = Game.new(players, last_worth)
  game.play
  winner, score = game.winner
  score
end


def part2(input : String) : UInt64
  players, last_worth = parse(input)
  last_worth *= 100

  game = Game.new(players, last_worth)
  game.play
  winner, score = game.winner
  score
end

if ARGF
  input = ARGF.gets_to_end.lines.first.chomp("\n")

  fmt_output = "%6s: %16s = %8s (took %8.3fms)\n"
  result1 = nil
  result2 = nil

  assert(part1("9 players; last marble is worth 25 points") == 32)

  assert(part1("10 players; last marble is worth 1618 points") == 8317)
  assert(part1("13 players; last marble is worth 7999 points") == 146373)
  assert(part1("17 players; last marble is worth 1104 points") == 2764)
  assert(part1("21 players; last marble is worth 6111 points") == 54718)
  assert(part1("30 players; last marble is worth 5807 points") == 37305)

  time1 = Benchmark.realtime do
    result1 = part1(input)
  end
  printf fmt_output, "part1", "winning score", result1, time1.total_milliseconds

  time2 = Benchmark.realtime do
    result2 = part2(input)
  end
  printf fmt_output, "part2", "winning score", result2, time2.total_milliseconds
end
