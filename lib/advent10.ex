defmodule Advent10 do
  def advent10 do
    case File.read("inputs/advent10.txt") do
      # case File.read("inputs/advent10test.txt") do
      {:ok, content} ->
        lines = Enum.reject(String.split(content, "\n"), fn s -> s == "" end)
        boxes = parse(lines, [])

        for box <- boxes do
          IO.puts(inspect(box))
        end

        IO.puts(sum(boxes, 0))
    end
  end

  def parse([line | tail], machines) do
    parse(tail, machines ++ [parse_line(line)])
  end

  def parse([], machines) do
    machines
  end

  def parse_line(line) do
    elems = String.split(line, " ")
    lights = Regex.replace(~r/\[|\]/, Enum.at(elems, 0), "")
    buttons = Enum.reject(elems, fn s -> String.at(s, 0) != "(" end)

    joltages =
      String.split(Regex.replace(~r/\{|\}/, Enum.at(elems, Enum.count(elems) - 1), ""), ",")

    buttons =
      buttons
      |> Enum.map(fn s ->
        strs = String.split(Regex.replace(~r/\(|\)/, s, ""), ",")
        Enum.map(strs, fn s -> must_parse_int(s) end)
      end)

    joltages =
      joltages
      |> Enum.map(fn s -> must_parse_int(s) end)

    {lights, buttons, joltages}
  end

  def must_parse_int(s) do
    case Integer.parse(s, 10) do
      {num, _} -> num
      _ -> -1
    end
  end

  def sum([], presses) do
    presses
  end

  def sum([machine | tail], presses) do
    IO.puts(presses)
    sum(tail, presses + fewest_button_presses(machine))
  end

  def fewest_button_presses({pattern, buttons, joltages}) do
    wanted =
      pattern
      |> String.graphemes
      |> Enum.with_index
      |> Enum.reject(fn {element, index} -> element != "#" end)
      |> Enum.map(fn {element, index} -> index end)
      IO.puts(inspect(wanted))
    fewest(wanted, buttons, [], 0,[])
  end

  def merge(a, b) do
    (a ++ b)
    |> Enum.frequencies
    |> Map.to_list
    |> Enum.reject(fn {elem, freq} -> freq != 1 end)
    |> Enum.map(fn {elem, freq} -> elem end)
  end

  def fewest(wanted, buttons, cur, times_merged,prev) do
    IO.puts(inspect(cur))
    if wanted == cur do
      times_merged
    else
      buttons
      |> Enum.reject(fn b -> b == cur or b == prev end)
      |> Enum.map(fn b -> fewest(wanted, buttons, merge(cur, b), times_merged + 1,cur) end)
      |> Enum.min
    end
  end
end
