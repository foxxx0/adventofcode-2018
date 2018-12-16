require "benchmark"

@[AlwaysInline]
def assert(condition)
  raise("assertion failed") unless condition
end

class SpreadTable
  property notes : Hash(String, Char)

  def initialize(@notes); end

  def next_gen(group : String) : Char
    # puts("checking #{group}")
    if @notes.has_key?(group)
      # pp(@notes[group])
      return @notes[group]
    else
      return '.'
    end
  end
end

def parse(input : Array(String)) : Tuple(String, SpreadTable)
  state = ""
  notes = {} of String => Char

  input.each do |line|
    next if line.empty?
    m1 = /^initial state: ([\#\.]+)/.match(line)
    m2 = /^([\#\.]+) => ([\#\.])/.match(line)
    raise "parse error" if m1.nil? && m2.nil?
    if !m1.nil? && m1.size == 2 && m2.nil?
      state = m1[1]
    elsif !m2.nil? && m2.size == 3 && m1.nil?
      notes[m2[1]] = m2[2].chars.first
    else
      raise "parse error"
    end
  end
  Tuple.new(state, SpreadTable.new(notes))
end

def iterate(state : String, lut : SpreadTable) : String
  result = ".."
  0.upto(state.size - 5).each do |idx|
    result += lut.next_gen(state[idx, 5])
  end
  result += ".."
  result
end

def plant_sum(state : String, offset : Int32) : Int64
  sum = 0i64
  state.each_char_with_index do |c, idx|
    sum += (idx - offset) if c == '#'
  end
  sum
end

def part1(input : Array(String)) : Int64
  state, lut = parse(input)
  state = "..." + state + "..."
  offset = 3
  # puts(state)
  20.times do
    state = iterate(state, lut)
    if state[2] == '#'
      state = "..." + state
      offset += 3
    end
    state += "..." if state[-3] == '#'
    # puts(state)
  end

  plant_sum(state, offset)
end


def part2(input : Array(String)) : Int64
  state, lut = parse(input)
  state = "..." + state + "..."
  offset = 3
  # puts(state)
  seen = Set(String).new
  start = 0
  last = 0
  plants = ""
  loop_at = 0
  shift_per_loop = 0
  sum_at_loop = 0
  abort_after_next = false
  loop_state = ""
  1.upto(1000).each do |gen|
    state = iterate(state, lut)
    if state[2] == '#'
      state = "..." + state
      offset += 3
    end
    state += "..." if state[-3] == '#'

    cur_s = 0
    cur_e = 0
    state.each_char_with_index { |c, i| if c == '#'; cur_s = i; break; end; }
    state.each_char_with_index { |c, i| cur_e = i if c == '#' }
    plants = state[cur_s, (cur_e - cur_s + 1)]
    if plants == loop_state && abort_after_next
        # puts("re-occured at generation #{gen} (offset #{offset}) with state:")
        # puts(plants)
        # puts("at index: #{cur_s}")
        cur_sum = plant_sum(state, offset)
        # puts("current sum = #{cur_sum}")
        shift_per_loop = cur_sum - sum_at_loop
        # puts("shift per loop: #{shift_per_loop}")
        break
    end
    if seen.includes?(plants)
      loop_at = gen
      start = cur_s
      last = cur_e
      # puts("found loop in generation #{gen} (offset #{offset}) with state:")
      # puts(plants)
      # puts("at index: #{start}")
      abort_after_next = true
      sum_at_loop = plant_sum(state, offset)
      # puts("current sum = #{sum_at_loop}")
      loop_state = plants
    else
      seen << plants
    end
  end
  (50_000_000_000i64 - loop_at) * shift_per_loop + sum_at_loop
end

if ARGF
  input = ARGF.gets_to_end.lines

  fmt_output = "%6s: %16s = %16s (took %8.3fms)\n"
  result1 = nil
  result2 = nil

  time1 = Benchmark.realtime do
    result1 = part1(input)
  end
  printf fmt_output, "part1", "sum", result1, time1.total_milliseconds

  time2 = Benchmark.realtime do
    result2 = part2(input)
  end
  printf fmt_output, "part2", "sum", result2, time2.total_milliseconds
end
