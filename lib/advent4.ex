defmodule Advent4 do
  def advent4 do
    case File.read("inputs/advent4.txt") do
      # case File.read("inputs/advent4test.txt") do
      {:ok, content} ->
        content = String.replace(content, "\r", "")
        lines = String.split(content, "\n")
        line = Enum.at(lines, 0)
        lines = Enum.slice(lines, 1, Enum.count(lines) - 1)
        g = to_graph(line, lines, 0, 0, %{})
        ary = Map.to_list(g)
        s = sum(ary, g, 0)
        IO.puts(s)
        r = part2(ary, g, 0)
        IO.puts(r)
    end
  end

  def done([], map) do
    true
  end

  def done([{[cx, cy], true} | tail], map) do
    if valid_neighbors([cx, cy], map) < 4 do
      false
    else
      done(tail, map)
    end
  end

  def remove_wave([], num_removed, map) do
    {num_removed, map}
  end

  def remove_wave([{[cx, cy], true} | tail], num_removed, map) do
    {m, removed} = remove_if_possible([cx, cy], map)

    if removed do
      remove_wave(tail, num_removed + 1, m)
    else
      remove_wave(tail, num_removed, map)
    end
  end

  def part2(ary, map, num_removed) do
    if done(ary, map) do
      num_removed
    else
      {removed, m} = remove_wave(ary, 0, map)
      part2(Map.to_list(m), m, num_removed + removed)
    end
  end

  def remove_if_possible([cx, cy], map) do
    v = valid_neighbors([cx, cy], map)

    if v < 4 do
      {Map.delete(map, [cx, cy]), true}
    else
      {map, false}
    end
  end

  def sum([], map, sum) do
    sum
  end

  def valid_neighbors([cx, cy], map, 0, 0, sum) do
    valid_neighbors([cx, cy], map, 0, 1, sum)
  end

  def valid_neighbors([cx, cy], map, 1, 1, sum) do
    if Map.get(map, [cx + 1, cy + 1]) do
      sum + 1
    else
      sum
    end
  end

  def valid_neighbors([cx, cy], map, x, 1, sum) do
    if Map.get(map, [cx + x, cy + 1]) do
      valid_neighbors([cx, cy], map, x + 1, -1, sum + 1)
    else
      valid_neighbors([cx, cy], map, x + 1, -1, sum)
    end
  end

  def valid_neighbors([cx, cy], map) do
    valid_neighbors([cx, cy], map, -1, -1, 0)
  end

  def valid_neighbors([cx, cy], map, x, y, sum) do
    if Map.get(map, [cx + x, cy + y]) do
      valid_neighbors([cx, cy], map, x, y + 1, sum + 1)
    else
      valid_neighbors([cx, cy], map, x, y + 1, sum)
    end
  end

  def sum([{[cx, cy], true} | tail], map, sum) do
    neighbors = valid_neighbors([cx, cy], map, -1, -1, 0)

    if neighbors < 4 do
      sum(tail, map, sum + 1)
    else
      sum(tail, map, sum)
    end
  end

  def to_graph("", [], x, y, map) do
    map
  end

  def to_graph("@" <> rest, [next | tail], x, y, map) do
    map = Map.put(map, [x, y], true)

    to_graph(rest, [next | tail], x + 1, y, map)
  end

  def to_graph("." <> rest, [next | tail], x, y, map) do
    to_graph(rest, [next | tail], x + 1, y, map)
  end

  def to_graph("", [next | tail], x, y, map) do
    to_graph(next, tail, 0, y + 1, map)
  end
end
