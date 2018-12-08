require "benchmark"

@[AlwaysInline]
def assert(condition)
  raise("assertion failed") unless condition
end

class Node
  property parent : Node|Nil
  property children : Array(Node)
  property metadata : Array(Int32)

  def initialize(@parent = nil, @children = [] of Node, @metadata = [] of Int32); end

  def meta_sum : Int32
    children.map { |c| c.meta_sum.as(Int32) }.sum + @metadata.sum
  end

  def value_sum : Int32
    sum = 0
    if children.size > 0
      metadata.each do |idx|
        next if idx > children.size || idx < 0
        sum += children[idx - 1].value_sum
      end
    else
      sum = @metadata.sum
    end
    sum
  end
end

def build_tree(items : Array(Int32), root : Node) : Node
  num_children = items.delete_at(0)
  num_metadata = items.delete_at(0)

  num_children.times do
    root.children << build_tree(items, Node.new(root))
  end

  num_metadata.times do
    root.metadata << items.delete_at(0)
  end

  root
end

def part1(license : String) : Int32
  items = license.split(' ').map(&.to_i)
  tree = build_tree(items, Node.new)
  tree.meta_sum
end


def part2(license : String) : Int32
  items = license.split(' ').map(&.to_i)
  tree = build_tree(items, Node.new)
  tree.value_sum
end

if ARGF
  input = ARGF.gets_to_end.lines.first.chomp("\n")

  fmt_output = "%6s: %16s = %8s (took %8.3fms)\n"
  result1 = nil
  result2 = nil

  # assert(part1("dabAcCaCBAcCcaDA") == 10)

  time1 = Benchmark.realtime do
    result1 = part1(input)
  end
  printf fmt_output, "part1", "metadata sum", result1, time1.total_milliseconds

  # assert(part2("dabAcCaCBAcCcaDA") == 4)

  time2 = Benchmark.realtime do
    result2 = part2(input)
  end
  printf fmt_output, "part2", "root value", result2, time2.total_milliseconds
end
