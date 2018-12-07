require "benchmark"

@[AlwaysInline]
def assert(condition)
  raise("assertion failed") unless condition
end

def parse_deps(instructions : Array(String)) : Hash(Char, Array(Char))
  deps = {} of Char => Array(Char)
  instructions.each do |line|
    m = /^Step (\w) must be finished before step (\w) can begin/.match(line)
    raise "parse error" if m.nil? || m.size != 3
    before = m[1].chars.first
    after = m[2].chars.first
    deps[before] = [] of Char unless deps.has_key?(before)
    deps[after] = [] of Char unless deps.has_key?(after)
    deps[after] << before unless deps[after].includes?(before)
  end
  deps
end

def instruction_order(deps : Hash(Char, Array(Char))) : Array(Char)
  order = [] of Char
  choices = [] of Char
  start = deps.select { |i, d| d.empty? }.keys.sort.first
  deps.delete(start)
  choices << start
  loop do
    step = choices.sort.first
    choices.delete(step)
    order << step
    deps.delete_if { |i, d| order.includes?(i) }
    break if deps.empty?
    choices = deps.select do |i, d|
      ! order.includes?(i) && (
      ( (d - (d & order)).size == 1 && (d - (d & order)).includes?(step) ) ||
        ( (d - (d & order)).empty? )
      )
    end.keys
  end
  order
end

class Worker
  property instruction : Char
  property second : Int32
  property offset : Int32

  def initialize(@instruction, @second, @offset); end

  def duration : Int32
    instruction.ord - 64 + offset
  end

  def tick
    @second += 1
  end

  def done? : Bool
    @second >= duration || @instruction == '.'
  end

  def busy? : Bool
    ! done?
  end

end


def part1(instructions : Array(String)) : String
  deps = parse_deps(instructions)
  order = instruction_order(deps)
  order.join
end


def part2(instructions : Array(String), parallel : Int32, offset : Int32) : Int32
  deps = parse_deps(instructions)
  order = instruction_order(deps.dup)

  workers = [] of Worker
  parallel.times do
    workers << Worker.new('.', 0, offset)
  end

  done = [] of Char
  seconds = 0
  #fmt = "%-8s %-10s %-10s %-6s\n"
  #printf fmt, "Second", "Worker 1", "Worker 2", "Done"
  #fmt = "   %-4s   %3s        %3s       %-6s\n"
  # fmt = "%-8s %-10s %-10s %-10s %-10s %-10s %-27s\n"
  # printf fmt, "Second", "Worker 1", "Worker 2", "Worker 3", "Worker 4", "Worker 5", "Done"
  # fmt = "   %-4s   %3s        %3s        %3s        %3s        %3s       %-27s\n"
  loop do
    invalid = (done + workers.map(&.instruction) - ['.']).uniq
    choices = deps.select do |i, d|
      ! invalid.includes?(i) && (d - (d & done)).empty?
    end.keys
    # dispatch work to idle workers if choices available
    workers.each do |w|
      # puts("choices for #{w}: #{choices}")
      # pp(w) if w.busy?
      if choices.size > 0
        # puts("w: #{w}, busy: #{w.busy?}")
        next if w.busy?
        step = choices.first
        choices.delete(step)
        w.instruction = step
        w.second = 0
      end
    end

    # let them work
    workers.select { |w| w.busy? }.map(&.tick)
    seconds += 1

    # check for finished work
    workers.each do |w|
      next if w.busy?
      if w.done? && w.instruction != '.' && ! done.includes?(w.instruction)
        done << w.instruction
      end
    end

    # printf fmt, seconds, workers[0].instruction, workers[1].instruction, done.join
    # printf fmt, seconds, workers[0].instruction, workers[1].instruction, workers[2].instruction, workers[3].instruction, workers[4].instruction, done.join
    # puts("second: #{seconds}")
    # puts("done: #{done.join}")
    break if done.size == order.size

    workers.each do |w|
      next if w.busy?
      w.instruction = '.' if w.done?
    end
  end
  seconds
end

if ARGF
  input = ARGF.gets_to_end.lines

  fmt_output = "%6s: %16s = %8s (took %8.3fms)\n"
  result1 = nil
  result2 = nil

  # assert(part1("dabAcCaCBAcCcaDA") == 10)

  time1 = Benchmark.realtime do
    result1 = part1(input)
  end
  printf fmt_output, "part1", "order", result1, time1.total_milliseconds

  # assert(part2("dabAcCaCBAcCcaDA") == 4)

  time2 = Benchmark.realtime do
    result2 = part2(input, 5, 60)
  end
  printf fmt_output, "part2", "duration", result2, time2.total_milliseconds
end
