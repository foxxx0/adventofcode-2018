require "benchmark"

@[AlwaysInline]
def assert(condition)
  raise("assertion failed") unless condition
end

def part1(input : Array(String)) : Int64
  freq_changes = input.map { |i| Int64.new(i) }

  freq = 0i64

  freq_changes.each do |change|
    freq += change
  end

  freq
end

def part2(input : Array(String)) : Int64
  freq_changes = input.map { |i| Int64.new(i) }

  freq = 0i64
  seen = Set(Int64).new

  loop do
    freq_changes.each do |change|
      freq += change
      return freq if seen.includes?(freq)
      seen.add(freq)
    end
  end
end

if ARGF
  input = ARGF.gets_to_end.lines

  fmt_output = "%6s: %16s = %8d (took %8.3fms)\n"
  result1 = nil
  result2 = nil

  assert(part1(["+1", "-2", "+3", "+1"]) == 3)

  time1 = Benchmark.realtime do
    result1 = part1(input)
  end
  printf fmt_output, "part1", "frequency", result1, time1.total_milliseconds

  assert(part2(["+3", "+3", "+4", "-2", "-4"]) == 10)

  time2 = Benchmark.realtime do
    result2 = part2(input)
  end
  printf fmt_output, "part2", "first duplicate", result2, time2.total_milliseconds
end
