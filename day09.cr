require "benchmark"

@[AlwaysInline]
def assert(condition)
  raise("assertion failed") unless condition
end

def parse(input : String) : Tuple(Int64, UInt64)
  m = /^(\d+) players; last marble is worth (\d+) points/.match(input)
  raise "parse error" if m.nil? || m.size != 3
  Tuple.new(m[1].to_i64, m[2].to_u64)
end

def pp_ring(ring : Deque(UInt64)) : Nil
  0.upto(ring.size - 1).each do |idx|
    printf " %d ", ring[idx]
  end
  printf "\n"
end

class Game
  property players : Hash(Int64, UInt64)
  property ring : Deque(UInt64)
  property marble_max : UInt64

  def initialize(num_players : Int64, @marble_max)
    @ring = Deque(UInt64).new
    @players = {} of Int64 => UInt64
    0i64.upto(num_players - 1).each do |player|
      @players[player] = 0u64
    end
  end

  def play
    # initial step
    ring.push(0i64)
    # pp_ring(ring)

    1u64.upto(@marble_max).each do |marble|
      if (marble % 23) == 0
        ring.rotate!(-7)
        player = (marble % @players.keys.size).to_i64
        removed = ring.shift
        @players[player] += marble + removed
      else
        ring.rotate!(2)
        ring.unshift(marble)
      end
      # pp_ring(ring)
    end
  end

  def winner : Tuple(Int64, UInt64)
    @players.max_by { |i, s| s }
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
