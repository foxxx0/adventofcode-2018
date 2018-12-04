require "benchmark"

@[AlwaysInline]
def assert(condition)
  raise("assertion failed") unless condition
end

def part1(input : Array(String)) : Int32
  proc = ->(hash : Hash(Int32, Array(Int32)), key : Int32) { hash[key] = [] of Int32 }
  guards = Hash(Int32, Array(Int32)).new(proc)
  guard = Tuple(Int32, Int32, Int32)
  sleep = 9999
  input.sort.each do |line|
    m = /^\[(\d+)-(\d+)-(\d+) (\d+):(\d+)\] (Guard #\d+ begins shift|falls asleep|wakes up)$/.match(line)
    raise "parse error" if m.nil? || m.size != 7
    year = m[1].to_i
    month = m[2].to_i
    day = m[3].to_i
    hour = m[4].to_i
    minute = m[5].to_i
    event = m[6]

    case event
    when "wakes up"
      guards[guard[0]].concat(sleep.upto(minute - 1)) unless guard.nil?
    when "falls asleep"
      sleep = minute
    else
      matchdata = /Guard #(\d+) begins shift/.match(event)
      raise "parse error" if matchdata.nil? || matchdata.size != 2
      guard = Tuple.new(matchdata[1].to_i, hour, minute)
    end
  end
  most_asleep_id = guards.max_by { |id, sleep_minutes| sleep_minutes.size }[0]
  minute_stats = Hash(Int32, Int32).new
  guards[most_asleep_id].uniq.each do |min|
    minute_stats[min] = guards[most_asleep_id].count(min)
  end
  most_asleep_minute = minute_stats.max_by { |m, times| times }[0]
  return most_asleep_id * most_asleep_minute
end

def part2(input : Array(String)) : Int32
  proc = ->(hash : Hash(Int32, Array(Int32)), key : Int32) { hash[key] = [] of Int32 }
  minutes = Hash(Int32, Array(Int32)).new(proc)
  guard = Tuple.new(nil, nil, nil)
  sleep = 9999
  input.sort.each do |line|
    m = /^\[(\d+)-(\d+)-(\d+) (\d+):(\d+)\] (Guard #\d+ begins shift|falls asleep|wakes up)$/.match(line)
    raise "parse error" if m.nil? || m.size != 7
    year = m[1].to_i
    month = m[2].to_i
    day = m[3].to_i
    hour = m[4].to_i
    minute = m[5].to_i
    event = m[6]

    case event
    when "wakes up"
      next if sleep.nil? || minute.nil? || guard[0].nil?
      sleep.upto(minute - 1).each do |minu|
        minutes[minu] << guard[0].not_nil!
      end
    when "falls asleep"
      sleep = minute
    else
      matchdata = /Guard #(\d+) begins shift/.match(event)
      raise "parse error" if matchdata.nil? || matchdata.size != 2
      guard = Tuple.new(matchdata[1].to_i, hour, minute)
    end
  end
  max = Tuple.new(0, 0, 0)
  minutes.values.flatten.uniq.each do |g|
    minutes.each do |m, sleeps|
      s = sleeps.count(g)
      max = Tuple.new(s, m, g) if s > max[0]
    end
  end
  return max[1] * max[2]
end

if ARGF
  input = ARGF.gets_to_end.lines

  fmt_output = "%6s: %16s = %8s (took %8.3fms)\n"
  result1 = nil
  result2 = nil

  # assert(part1(["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"]) == 4)

  time1 = Benchmark.realtime do
    result1 = part1(input)
  end
  printf fmt_output, "part1", "id * minute", result1, time1.total_milliseconds

  # assert(part2(["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"]) == 3)

  time2 = Benchmark.realtime do
    result2 = part2(input)
  end
  printf fmt_output, "part2", "id * minute", result2, time2.total_milliseconds
end
