require "benchmark"

@[AlwaysInline]
def assert(condition)
  raise("assertion failed") unless condition
end

class Claim
  property id : Int32
  property x : Int32
  property y : Int32
  property width : Int32
  property height : Int32

  def initialize(@id, @x, @y, @width, @height); end
end

def part1(input : Array(String)) : Int32
  fabric = Hash(Int32, Hash(Int32, Int32)).new
  0.upto(1000).each do |y|
    fabric[y] = Hash(Int32, Int32).new
    0.upto(1000).each do |x|
      fabric[y][x] = 0
    end
  end

  claims = [] of Claim
  input.each do |line|
    m = /^#(\d+) @ (\d+),(\d+): (\d+)x(\d+)$/.match(line)
    raise "parse error" if m.nil? || m.size != 6
    claim = Claim.new(m[1].to_i, m[2].to_i, m[3].to_i, m[4].to_i, m[5].to_i)
    claims << claim
    (claim.y).upto(claim.y + claim.height - 1).each do |y|
      (claim.x).upto(claim.x + claim.width - 1).each do |x|
        fabric[y][x] += 1
      end
    end
  end
  return fabric.values.map(&.values).map(&.select { |x| x > 1 }.size).sum
end

def part2(input : Array(String)) : Int32|Nil
  fabric = Hash(Int32, Hash(Int32, Int32)).new
  0.upto(1000).each do |y|
    fabric[y] = Hash(Int32, Int32).new
    0.upto(1000).each do |x|
      fabric[y][x] = 0
    end
  end

  claims = [] of Claim
  input.each do |line|
    m = /^#(\d+) @ (\d+),(\d+): (\d+)x(\d+)$/.match(line)
    raise "parse error" if m.nil? || m.size != 6
    claim = Claim.new(m[1].to_i, m[2].to_i, m[3].to_i, m[4].to_i, m[5].to_i)
    claims << claim
    (claim.y).upto(claim.y + claim.height - 1).each do |y|
      (claim.x).upto(claim.x + claim.width - 1).each do |x|
        fabric[y][x] += 1
      end
    end
  end

  claims.each do |claim|
    uncontested = [] of Tuple(Int32, Int32)
    (claim.y).upto(claim.y + claim.height - 1).each do |y|
      (claim.x).upto(claim.x + claim.width - 1).each do |x|
        uncontested << Tuple.new(x, y) if fabric[y][x] == 1
      end
    end
    return claim.id if uncontested.size == (claim.width * claim.height)
  end
end

if ARGF
  input = ARGF.gets_to_end.lines

  fmt_output = "%6s: %16s = %8s (took %8.3fms)\n"
  result1 = nil
  result2 = nil

  assert(part1(["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"]) == 4)

  time1 = Benchmark.realtime do
    result1 = part1(input)
  end
  printf fmt_output, "part1", "overlapped", result1, time1.total_milliseconds

  assert(part2(["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"]) == 3)

  time2 = Benchmark.realtime do
    result2 = part2(input)
  end
  printf fmt_output, "part2", "uncontested id", result2, time2.total_milliseconds
end
