defmodule Advent1 do


  def advent1 do
    case File.read("inputs/advent1.txt") do
      # case File.read("inputs/advent1test.txt") do
      {:ok, content} ->
        content = String.replace(content, "\r", "")
        lines = String.split(content, "\n")
        {start, next} = Enum.split(lines, 1)
        line = Enum.at(start, 0)
        {part1,part2}= next(line, next, 0, 50, 1)
        IO.puts(part1)
        IO.puts(part2)
    end
  end

  def next("L" <> rest, [], zero_count, cur_sum, zero_count_pt1) do
    restNum = Integer.parse(rest, 10)

    case restNum do
      :error ->
        exit("bad")
      {number, ""} ->
        zeroes_to_add = cur_sum - number
        div = abs(Integer.floor_div(zeroes_to_add, 100))
        zero_count = zero_count + div - to_int(cur_sum == 0 && div > 0)
        modNum = Integer.mod(cur_sum - number, 100)
        num = Integer.mod(max(modNum, 100 - modNum), 100)

        if num == 0 do
          {zero_count + 1, zero_count_pt1 + 1}
        else
          {zero_count, zero_count_pt1}
        end
    end
  end

  def next("L" <> rest, [next_line | next_lines], zero_count, cur_sum, zero_count_pt1) do
    restNum = Integer.parse(rest, 10)
    case restNum do
      :error ->
        exit("bad")
      {number, ""} ->
        zeroes_to_add = cur_sum - number
        zc = zero_count
        div = abs(Integer.floor_div(zeroes_to_add, 100))
        zc = zc + div
        zc = zc - to_int(cur_sum == 0 && div > 0)
        modNum = Integer.mod(cur_sum - number, 100)
        num = modNum
        if num == 0 do
          next(next_line, next_lines, zc + 1, num, zero_count_pt1 + 1)
        else
          next(next_line, next_lines, zc, num, zero_count_pt1)
        end
    end
  end

  def to_int(bool) do
    if bool, do: 1, else: 0
  end

  def next("R" <> rest, [], zero_count, cur_sum, zero_count_pt1) do
    restNum = Integer.parse(rest, 10)

    case restNum do
      :error ->
        exit("bad")
      {number, ""} ->
        zeroes_to_add = cur_sum + number
        zero_count =
          zero_count + abs(Integer.floor_div(zeroes_to_add, 100)) - to_int(zeroes_to_add == 100) -
            to_int(
              cur_sum == 0 && abs(Integer.floor_div(zeroes_to_add, 100)) > 0 &&
                zeroes_to_add != 100
            )
        num = Integer.mod(cur_sum + number, 100)
        if num == 0 do
          {zero_count_pt1 + 1,zero_count+1}
        else
          {zero_count_pt1,zero_count}
        end
    end
  end

  def next("R" <> rest, [next_line | next_lines], zero_count, cur_sum, zero_count_pt1) do
    restNum = Integer.parse(rest, 10)

    case restNum do
      :error ->
        exit("bad")
      {number, ""} ->
        zeroes_to_add = cur_sum + number
        zero_count =
          zero_count + abs(Integer.floor_div(zeroes_to_add, 100))
        num = Integer.mod(cur_sum + number, 100)
        next(next_line, next_lines, zero_count, num, zero_count_pt1 + to_int(num == 0))
    end
  end

  def next("", [], zero_count, cur_sum, zero_count_pt1) do
    {zero_count_pt1,zero_count}
  end
end
