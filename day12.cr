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

def part1(input : Array(String)) : Int32
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
  sum = 0
  state.chars.each_with_index do |c, idx|
    sum += (idx - offset) if c == '#'
  end
  sum
end


def part2(input : Array(String)) : String
  ""
end

if ARGF
  input = ARGF.gets_to_end.lines

  fmt_output = "%6s: %16s = %8s (took %8.3fms)\n"
  result1 = nil
  result2 = nil

  time1 = Benchmark.realtime do
    result1 = part1(input)
  end
  printf fmt_output, "part1", "sum", result1, time1.total_milliseconds

  # time2 = Benchmark.realtime do
    # result2 = part2(input)
  # end
  # printf fmt_output, "part2", "best square", result2, time2.total_milliseconds
end
