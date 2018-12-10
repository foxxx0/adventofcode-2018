require "benchmark"

@[AlwaysInline]
def assert(condition)
  raise("assertion failed") unless condition
end

VECTOR = /\s*[-]*\d+,\s*[-]*\d+/
STAR = /^position=<(?<p>#{VECTOR})> velocity=<(?<v>#{VECTOR})>/

class Star
  property p : Tuple(Int32, Int32)
  property v : Tuple(Int32, Int32)

  def initialize(@p, @v); end

  def tick : Nil
    @p = { @p[0] + @v[0], @p[1] + @v[1] }
  end

  def rewind : Nil
    @p = { @p[0] - @v[0], @p[1] - @v[1] }
  end
end

class Universe
  property stars : Array(Star)
  property second : Int32

  def initialize(@stars = [] of Star)
    @second = 0
  end

  def tick : Nil
    stars.map(&.tick)
    @second += 1
  end

  def rewind : Nil
    stars.map(&.rewind)
    @second -= 1
  end

  def bounds : Tuple(Tuple(Int32, Int32), Tuple(Int32, Int32))
    Tuple.new(
      Tuple.new(
        @stars.min_by { |s| s.p[0] }.p[0],
        @stars.min_by { |s| s.p[1] }.p[1]
      ),
      Tuple.new(
        @stars.max_by { |s| s.p[0] }.p[0],
        @stars.max_by { |s| s.p[1] }.p[1]
      )
    )
  end

  def dimensions : Tuple(Int32, Int32)
    min, max = self.bounds
    Tuple.new(
      max[0] - min[0],
      max[1] - min[1]
    )
  end
end

def parse(input : Array(String)) : Universe
  universe = Universe.new
  input.each do |line|
    m = STAR.match(line)
    raise "parse error" if m.nil? || m.not_nil!.size != 3
    cur = {} of String => Tuple(Int32, Int32)
    %w[p v].each do |vec|
      tmp = m.try &.[vec].split(',').map(&.chomp).map(&.to_i)
      cur[vec] = Tuple.new(tmp[0], tmp[1])
    end
    universe.stars << Star.new(cur["p"], cur["v"])
  end
  universe
end

def part12(input : Array(String)) : Int32
  universe = parse(input)
  sizes = Tuple.new(Int32::MAX, Int32::MAX)
  loop do
    span_x, span_y = universe.dimensions
    if span_x < sizes[0] && span_y < sizes[1]
      sizes = { span_x, span_y }
      universe.tick
    else
      universe.rewind
      bounds = universe.bounds
      bounds[0][1].upto(bounds[1][1]).each do |y|
        bounds[0][0].upto(bounds[1][0]).each do |x|
          cur = universe.stars.select { |s| s.p[0] == x && s.p[1] == y }
          if cur.empty?
            printf(" ")
          else
            printf("█")
          end
        end
        printf("\n")
      end
      break
    end
  end
  universe.second
end


def part2(input : Array(String)) : Int32
  universe = parse(input)
  sizes = Tuple.new(Int32::MAX, Int32::MAX)
  seconds = 0
  loop do
    span_x, span_y = universe.dimensions
    if x < sizes[0] && y < sizes[1]
      sizes = { x, y }
      universe.tick
      seconds += 1
    else
      stars.map(&.rewind)
      seconds -= 1
      break
    end
  end
  seconds
end

if ARGF
  input = ARGF.gets_to_end.lines

  fmt_output = "%6s: %16s = %8s (took %8.3fms)\n"
  result1 = nil
  result2 = nil

  time1 = Benchmark.realtime do
    result2 = part12(input)
  end
  printf fmt_output, "part1", "message", result1, time1.total_milliseconds
  printf fmt_output, "part2", "seconds", result2, 0.0
end
