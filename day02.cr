require "benchmark"

@[AlwaysInline]
def assert(condition)
  raise("assertion failed") unless condition
end

def part1(input : Array(String)) : Int64
  twice = 0i64
  thrice = 0i64
  input.each do |id|
    id2 = false
    id3 = false
    uqc = id.chars.sort.uniq
    uqc.each do |c|
      occurances = id.count(c)
      case occurances
      when 3
        id3 = true
      when 2
        id2 = true
      end
    end
    thrice += 1 if id3
    twice += 1 if id2
  end
  return twice * thrice
end

def part2(input : Array(String)) : String|Nil
  char_arys = input.map(&.chars)
  char_arys.each do |id|
    char_arys.each do |compare|
      next if compare == id
      common = Array(Char).new
      mismatches = Array(Int32).new
      0.upto(id.size - 1).each do |idx|
        if compare[idx] == id[idx]
          common << id[idx]
        else
          mismatches << idx
        end
      end
      if mismatches.size == 1
        return common.join
      end
    end
  end
end

if ARGF
  input = ARGF.gets_to_end.lines

  fmt_output = "%6s: %16s = %8s (took %8.3fms)\n"
  result1 = nil
  result2 = nil

  assert(part1(%w[abcdef bababc abbcde abcccd aabcdd abcdee ababab]) == 12)

  time1 = Benchmark.realtime do
    result1 = part1(input)
  end
  printf fmt_output, "part1", "checksum", result1, time1.total_milliseconds

  assert(part2(%w[abcde fghij klmno pqrst fguij axcye wvxyz]) == "fgij")

  time2 = Benchmark.realtime do
    result2 = part2(input)
  end
  printf fmt_output, "part2", "common chars", result2, time2.total_milliseconds
end
