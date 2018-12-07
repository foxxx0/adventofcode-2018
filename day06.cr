require "benchmark"

@[AlwaysInline]
def assert(condition)
  raise("assertion failed") unless condition
end

def distance(p1 : Tuple(Int32, Int32), p2 : Tuple(Int32, Int32)) : Int32
  [(p2[0] - p1[0]), (p2[1] - p1[1])].map(&.abs).sum
end

def part1(input : Array(String)) : Int32
  coords = [] of Tuple(Int32, Int32)
  input.each do |pnt|
    x, y = pnt.split(", ").map(&.to_i)
    coords << Tuple.new(x, y)
  end

  x_min = coords.min_by { |p| p[0] }[0]
  x_max = coords.max_by { |p| p[0] }[0]
  y_min = coords.min_by { |p| p[1] }[1]
  y_max = coords.max_by { |p| p[1] }[1]

  # puts("choosing finite candidates from (#{x_min}, #{y_min}) to (#{x_max}, #{y_max})")
  finite_candidates = coords.select { |p| p[0] > x_min && p[0] < x_max && p[1] > y_min && p[1] < y_max }

  x_min -= 10
  x_max += 10
  y_min -= 10
  y_max += 10

  # puts("extending grid: from (#{x_min}, #{y_min}) to (#{x_max}, #{y_max})")

  areas = {} of Tuple(Int32, Int32) => Array(Tuple(Int32, Int32))
  coords.each do |c|
    areas[c] = [] of Tuple(Int32, Int32)
    areas[c] << c
  end

  x_min.upto(x_max).each do |x|
    y_min.upto(y_max) do |y|
      cur = Tuple.new(x, y)
      dists = {} of Int32 => Array(Tuple(Int32, Int32))

      coords.each do |c|
        dist = distance(c, cur)
        dists[dist] = [] of Tuple(Int32, Int32) unless dists.has_key?(dist)
        dists[dist] << c
      end

      min = dists.keys.min
      next if min == 0 || dists.keys.count(min) > 1

      areas[dists[min][0]] << cur if areas.has_key?(dists[min][0])
    end
  end

  # pp(areas.select { |p, s| finite_candidates.includes?(p) })
  areas.each do |p, s|
    # puts("#{p} : #{finite_candidates.includes?(p)}")
    if finite_candidates.includes?(p)
      # puts("#{p}:")
      if s.select { |c| c[0] == x_min || c[0] == x_max || c[1] == y_min || c[1] == y_max }.size > 0
        # puts("discarding #{p} as a finite candidate")
        finite_candidates.delete(p)
      end
    end
  end
  areas.select { |p, s| finite_candidates.includes?(p) }.max_by { |p| p[1].size }[1].size
end


def safe_area(coords : Array(Tuple(Int32, Int32)), max_dist_sum : Int32) : Hash(Tuple(Int32, Int32), Int32)
  x_min = coords.min_by { |p| p[0] }[0]
  x_max = coords.max_by { |p| p[0] }[0]
  y_min = coords.min_by { |p| p[1] }[1]
  y_max = coords.max_by { |p| p[1] }[1]

  x_min -= Math.sqrt(max_dist_sum.abs).floor.to_i
  x_max += Math.sqrt(max_dist_sum.abs).floor.to_i
  y_min -= Math.sqrt(max_dist_sum.abs).floor.to_i
  y_max += Math.sqrt(max_dist_sum.abs).floor.to_i

  # puts("extending grid: from (#{x_min}, #{y_min}) to (#{x_max}, #{y_max})")

  areas = {} of Tuple(Int32, Int32) => Int32

  x_min.upto(x_max).each do |x|
    y_min.upto(y_max) do |y|
      cur = Tuple.new(x, y)
      areas[cur] = 0

      coords.each do |c|
        areas[cur] += distance(c, cur)
      end
    end
  end

  areas.select { |a, s| s < max_dist_sum }
end


def part2(input : Array(String), max_dist_sum : Int32) : Int32
  coords = [] of Tuple(Int32, Int32)
  input.each do |pnt|
    x, y = pnt.split(", ").map(&.to_i)
    coords << Tuple.new(x, y)
  end

  safe = safe_area(coords, max_dist_sum)
  safe.size
end

if ARGF
  input = ARGF.gets_to_end.lines

  fmt_output = "%6s: %16s = %8s (took %8.3fms)\n"
  result1 = nil
  result2 = nil

  assert(part1(["1, 1", "1, 6", "8, 3", "3, 4", "5, 5", "8, 9"]) == 17)

  time1 = Benchmark.realtime do
    result1 = part1(input)
  end
  printf fmt_output, "part1", "largest area", result1, time1.total_milliseconds

  assert(part2(["1, 1", "1, 6", "8, 3", "3, 4", "5, 5", "8, 9"], 32) == 16)

  time2 = Benchmark.realtime do
    result2 = part2(input, 10000)
  end
  printf fmt_output, "part2", "safe area size", result2, time2.total_milliseconds
end
