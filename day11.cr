require "benchmark"

@[AlwaysInline]
def assert(condition)
  raise("assertion failed") unless condition
end

class Fuelcell
  property x : Int32
  property y : Int32
  property power : Int32
  def initialize(@x, @y, @power = Int32::MIN); end

  def calc_power(serial : Int32) : Nil
    return nil if @power > Int32::MIN
    rack_id = @x + 10
    # puts("rack_id = #{rack_id}")
    level = rack_id * @y
    # puts("level = #{level}")
    level += serial
    # puts("level = #{level}")
    level *= rack_id
    # puts("level = #{level}")
    hundreds = level > 99 ? level.to_s[-3].to_i : 0
    # puts("hundreds = #{hundreds}")
    result = hundreds - 5
    # puts("result = #{result}")
    @power = result
    nil
  end
end

class Grid
  property serial : Int32
  property fuel_cells : Hash(Int32, Hash(Int32, Fuelcell))

  def initialize(@serial)
    @fuel_cells = {} of Int32 => Hash(Int32, Fuelcell)
    1.upto(300).each do |y|
      @fuel_cells[y] = {} of Int32 => Fuelcell
      1.upto(300).each do |x|
        @fuel_cells[y][x] = Fuelcell.new(x, y)
        @fuel_cells[y][x].calc_power(@serial)
      end
    end
  end

  def to_square(x : Int32, y : Int32, s : Int32) : Array(Array(Int32))
    @fuel_cells.select(y.upto(y + s - 1).to_a).map(&.[1]).map { |r| r.select(x.upto(x + s - 1).to_a) }.map(&.values).map { |r| r.map(&.power) }
  end

  def best_3x3 : Tuple(Int32, Int32)
    power = {} of Int32 => Tuple(Int32, Int32)
    1.upto(298).each do |y|
      1.upto(298).each do |x|
        cur = 0
        y.upto(y + 2).each do |ay|
          x.upto(x + 2).each do |ax|
            cur += @fuel_cells[ay][ax].power
          end
        end
        power[cur] = Tuple.new(x, y)
      end
    end
    Tuple.new(0, 0)
    power.max_by { |p, t| p }[1]
  end

  def best_square : Tuple(Int32, Int32, Int32, Int32)
    max = Tuple.new(Int32::MIN, 0, 0, 0)
    data = self.to_square(1, 1, 300)
    0.upto(299).each do |y|
      row_time = Benchmark.realtime do
        0.upto(299).each do |x|
          # puts("calculating from #{x},#{y}")
          max_size = 300 - [x, y].max
          1.upto(max_size).each do |size|
            # pp(data[y, size].map(&.[x, size]).flatten.sum)
            cur = data[y, size].map(&.[x, size]).flatten.sum
            max = Tuple.new(cur, x + 1, y + 1, size) if cur > max[0]
          end
        end
      end
      if (y + 1) % 3 == 0
        printf "finished row %3d - %3d%% (last row took %8.3fms)\n", y + 1, ((y + 1) / 3).floor.to_i, row_time.total_milliseconds
      end
    end
    max
  end
end

def part1(serial : Int32) : String
  grid = Grid.new(serial)
  result = grid.best_3x3
  "#{result[0]},#{result[1]}"
end


def part2(serial : Int32) : String
  grid = Grid.new(serial)
  result = grid.best_square
  "#{result[1]},#{result[2]},#{result[3]} (power #{result[0]})"
end

if ARGF
  input = ARGF.gets_to_end.lines.first.chomp("\n").to_i

  fmt_output = "%6s: %16s = %8s (took %8.3fms)\n"
  result1 = nil
  result2 = nil

  time1 = Benchmark.realtime do
    result1 = part1(input)
  end
  printf fmt_output, "part1", "best 3x3 coord", result1, time1.total_milliseconds

  time2 = Benchmark.realtime do
    result2 = part2(input)
  end
  printf fmt_output, "part2", "best square", result2, time2.total_milliseconds
end
