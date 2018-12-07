require "benchmark"

@[AlwaysInline]
def assert(condition)
  raise("assertion failed") unless condition
end

def part1(polymer : String) : Int32
  p = polymer.chars
  loop do
    reacted = false
    idx = 0
    while idx < (p.size - 2)
      if p[idx].ord == (p[idx + 1].ord - 32) || p[idx].ord == (p[idx + 1].ord + 32)
        p.delete_at(idx, 2)
        reacted = true
      else
        idx += 1
      end
    end
    break unless reacted
  end
  p.size
end

def part2(polymer : String) : Int32
  sizes = Hash(Char, Int32).new
  polymer.chars.map(&.downcase).uniq.each do |c|
    x = polymer
    x = x.delete(c)
    x = x.delete((c.ord - 32).chr)
    p = x.chars
    loop do
      reacted = false
      idx = 0
      while idx < (p.size - 2)
        if p[idx].ord == (p[idx + 1].ord - 32) || p[idx].ord == (p[idx + 1].ord + 32)
          p.delete_at(idx, 2)
          reacted = true
        else
          idx += 1
        end
      end
      break unless reacted
    end
    sizes[c] = p.size
  end
  sizes.min_by { |c, s| s }[1]
end

if ARGF
  input = ARGF.gets_to_end.lines.first.chomp("\n")

  fmt_output = "%6s: %16s = %8s (took %8.3fms)\n"
  result1 = nil
  result2 = nil

  assert(part1("dabAcCaCBAcCcaDA") == 10)

  time1 = Benchmark.realtime do
    result1 = part1(input)
  end
  printf fmt_output, "part1", "units", result1, time1.total_milliseconds

  assert(part2("dabAcCaCBAcCcaDA") == 4)

  time2 = Benchmark.realtime do
    result2 = part2(input)
  end
  printf fmt_output, "part2", "smallest", result2, time2.total_milliseconds
end
