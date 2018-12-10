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

  def tick
    @p = { @p[0] + @v[0], @p[1] + @v[1] }
  end

  def rewind
    @p = { @p[0] - @v[0], @p[1] - @v[1] }
  end
end

def parse(input : Array(String)) : Array(Star)
  stars = [] of Star
  input.each do |line|
    m = STAR.match(line)
    raise "parse error" if m.nil? || m.not_nil!.size != 3
    cur = {} of String => Tuple(Int32, Int32)
    %w[p v].each do |vec|
      tmp = m.try &.[vec].split(',').map(&.chomp).map(&.to_i)
      cur[vec] = Tuple.new(tmp[0], tmp[1])
    end
    stars << Star.new(cur["p"], cur["v"])
  end
  stars
end

def part1(input : Array(String)) : Int32
  stars = parse(input)
  sizes = Tuple.new(Int32::MAX, Int32::MAX)
  loop do
    x_min = stars.min_by { |s| s.p[0] }.p[0]
    x_max = stars.max_by { |s| s.p[0] }.p[0]
    y_min = stars.min_by { |s| s.p[1] }.p[1]
    y_max = stars.max_by { |s| s.p[1] }.p[1]
    x = (x_max - x_min)
    y = (y_max - y_min)
    if x < sizes[0] && y < sizes[1]
      sizes = { x, y }
      stars.map(&.tick)
    else
      stars.map(&.rewind)
      y_min.upto(y_max).each do |y|
        x_min.upto(x_max).each do |x|
          cur = stars.select { |s| s.p[0] == x && s.p[1] == y }
          if cur.empty?
            printf(" ")
          else
            printf("#")
          end
        end
        printf("\n")
      end
      break
    end
  end
  0
end


def part2(input : Array(String)) : Int32
  stars = parse(input)
  sizes = Tuple.new(Int32::MAX, Int32::MAX)
  seconds = 0
  loop do
    x_min = stars.min_by { |s| s.p[0] }.p[0]
    x_max = stars.max_by { |s| s.p[0] }.p[0]
    y_min = stars.min_by { |s| s.p[1] }.p[1]
    y_max = stars.max_by { |s| s.p[1] }.p[1]
    x = (x_max - x_min)
    y = (y_max - y_min)
    if x < sizes[0] && y < sizes[1]
      sizes = { x, y }
      stars.map(&.tick)
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
    result1 = part1(input)
  end
  printf fmt_output, "part1", "message", result1, time1.total_milliseconds

  time2 = Benchmark.realtime do
    result2 = part2(input)
  end
  printf fmt_output, "part2", "seconds", result2, time2.total_milliseconds
end
