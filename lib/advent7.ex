defmodule Advent7 do
  def advent7 do
    # case File.read("inputs/advent7.txt") do
      case File.read("inputs/advent7test.txt") do
      {:ok, content} ->
        lines = String.split(content, "\n")
        max_x = Enum.count(lines)
        max_y = String.length(Enum.at(lines, 0))
        splitters = parse(lines, 0, %{})
        start_y = find_start_y(Enum.at(lines, 0), 0)
        {splits, visited} = num_splits(0, start_y, splitters, max_x, max_y, %{})
        IO.puts(splits)
        # {timelines, visited} = timelines_reverse(max_x, start_y, splitters, start_y, max_y)
        sum = 0

        # for i <- 0..max_y do
        #   timelines = timelines_reverse(max_x, i, splitters, start_y, max_y)

        #   IO.puts("-------")
        #   IO.puts(timelines)
        #   IO.puts(i)
        #   IO.puts("-------")
        # end
        IO.puts(start_y)

        nlm = timelines_map(0, 0, Map.put(%{},start_y,1), splitters, max_x, max_y, %{})
        IO.puts(Enum.count(nlm))

        # for {col, num} <- Map.to_list(nlm) do
        #   IO.puts(col)
        #   IO.puts(num)
        # end

        ary = Enum.map(Map.to_list(nlm), fn {col, num} -> num end)

        sum = Enum.sum(ary)
        IO.puts(sum)
    end
  end

  def parse([], index, splitters) do
    splitters
  end

  def parse([line | tail], index, splitters) do
    splitters = parse_line(line, index, 0, splitters)
    parse(tail, index + 1, splitters)
  end

  def parse_line("", index, jindex, splitters) do
    splitters
  end

  def find_start_y("S" <> rest, index) do
    index
  end

  def find_start_y("." <> rest, index) do
    find_start_y(rest, index + 1)
  end

  def parse_line(line, index, jindex, splitters) do
    case String.slice(line, 0, 1) do
      "^" ->
        parse_line(
          String.slice(line, 1, String.length(line) - 1),
          index,
          jindex + 1,
          Map.put(splitters, [index, jindex], true)
        )

      char when char == "\r" or char == "\n" ->
        splitters

      _ ->
        parse_line(String.slice(line, 1, String.length(line) - 1), index, jindex + 1, splitters)
    end
  end

  def num_splits(i, j, splitters, max_x, max_y, visited) do
    if i >= max_x || j > max_y || j < 0 || Map.get(visited, [i, j], false) do
      IO.puts("zero")
      {0, visited}
    else
      visited = Map.put(visited, [i, j], true)

      if Map.get(splitters, [i, j], false) do
        {l, visited2} = num_splits(i, j - 1, splitters, max_x, max_y, visited)
        {r, visited3} = num_splits(i, j + 1, splitters, max_x, max_y, visited2)
        {l + r + 1, visited3}
      else
        num_splits(i + 1, j, splitters, max_x, max_y, visited)
      end
    end
  end

  def timelines(i, j, splitters, max_x, max_y, visited) do
    if i >= max_x || j > max_y || j < 0 || Map.get(visited, [i, j], false) do
      IO.puts("zero")
      {1, visited}
    else
      visited = Map.put(visited, [i, j], true)

      if Map.get(splitters, [i, j], false) do
        {l, visited2} = timelines(i, j - 1, splitters, max_x, max_y, visited)
        {r, visited3} = timelines(i, j + 1, splitters, max_x, max_y, visited2)
        {r + l, visited}
      else
        timelines(i + 1, j, splitters, max_x, max_y, visited)
      end
    end
  end

  def timelines_reverse(i, j, splitters, start_y, max_y) do
    next = [i - 1, j]

    if i - 1 == 0 && j == start_y do
      1
    else
      if Map.get(splitters, next, false) or i <= 1 or j < 0 or j > max_y do
        # we are on top of a splitter, meaning this is impossible, or we are out of bounds
        0
      else
        continue = timelines_reverse(i - 1, j, splitters, start_y, max_y)

        if Map.get(splitters, [i - 1, j - 1], false) and Map.get(splitters, [i - 1, j + 1], false) do
          left_tl = timelines_reverse(i - 1, j - 1, splitters, start_y, max_y)
          right_tl = timelines_reverse(i - 1, j + 1, splitters, start_y, max_y)
          left_tl + right_tl + continue
        else
          if Map.get(splitters, [i - 1, j - 1], false) do
            left_tl = timelines_reverse(i - 1, j - 1, splitters, start_y, max_y)
            left_tl + continue
          else
            if Map.get(splitters, [i - 1, j + 1], false) do
              right_tl = timelines_reverse(i - 1, j + 1, splitters, start_y, max_y)
              right_tl + continue
            else
              continue
            end
          end
        end
      end
    end
  end

  def timelines_map(level, y, level_map, splitters, max_x, max_y, next_level_map) do
    if level > max_x do
      level_map
    else
      if y > max_y do
        timelines_map(level + 1, 0, next_level_map, splitters, max_x, max_y, %{})
      else
        cur = Map.get(level_map, y, 0)
        # if cur > 0 do
        #   IO.puts(cur)
        # end
        cur_pre = Map.get(next_level_map,y,0)

        if Map.get(splitters, [level, y], false) do
          left_pre = Map.get(next_level_map, y - 1, 0)
          right_pre = Map.get(next_level_map, y + 1, 0)
          # IO.puts(left_pre)
          nlm = Map.put(next_level_map, y - 1, left_pre + cur)
          nlm = Map.put(nlm, y + 1, right_pre + cur)
          timelines_map(level, y + 1, level_map, splitters, max_x, max_y, nlm)
        else

          nlm = Map.put(next_level_map, y, cur+cur_pre)
          timelines_map(level, y + 1, level_map, splitters, max_x, max_y, nlm)
        end
      end
    end
  end
end
