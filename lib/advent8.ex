defmodule Advent8 do
  def advent8 do
    case File.read("inputs/advent8.txt") do
      # case File.read("inputs/advent8test.txt") do
      {:ok, content} ->
        lines = String.split(content, "\n")
        boxes = parse(lines, [])

        for box <- boxes do
          IO.puts(Enum.join(box, ","))
        end

        # circuits = join(boxes, 999)
        # circuits = join(boxes,9)
        # IO.puts(Enum.count(circuits))
        # # {timelines, visited} = timelines_reverse(max_x, start_y, splitters, start_y, max_y)
        # circuits =
        #   Enum.sort(circuits, fn a, b ->
        #     Enum.count(Map.to_list(a)) > Enum.count(Map.to_list(b))
        #   end)

        # IO.puts(inspect(circuits))
        # IO.puts(inspect(Enum.map(circuits, fn m -> Enum.count(m) end)))
        last_joined = join_no_max(boxes)
        IO.puts(inspect(last_joined))
    end
  end

  def parse([""], boxes) do
    boxes
  end

  def parse([line | tail], boxes) do
    num_strings = String.split(String.replace(line, "\r", ""), ",")
    nums = Enum.map(num_strings, fn num_string -> elem(Integer.parse(num_string, 10), 0) end)
    parse(tail, boxes ++ [nums])
  end

  def parse([], boxes) do
    boxes
  end

  def distance([a, b, c], [d, e, f]) do
    :math.sqrt((d - a) * (d - a) + (e - b) * (e - b) + (f - c) * (f - c))
  end

  def closest_to_given(_, [], closest, closest_distance, joined_already) do
    # IO.puts "closest"
    {closest, closest_distance}
  end

  def closest_to_given([a, b, c], [[d, e, f] | tail], closest, closest_distance, joined_already) do
    # IO.puts(Enum.join([d,e,f],","))

    if Map.get(joined_already, [[a, b, c], [d, e, f]], false) do
      # IO.puts("joined already")
      closest_to_given([a, b, c], tail, closest, closest_distance, joined_already)
    else
      di = distance([a, b, c], [d, e, f])

      if di < closest_distance or Map.get(joined_already, [[a, b, c], closest], false) do
        # IO.puts("new closest")
        closest_to_given([a, b, c], tail, [d, e, f], di, joined_already)
      else
        # IO.puts("no new closest")
        closest_to_given([a, b, c], tail, closest, closest_distance, joined_already)
      end
    end
  end

  def closest_pair([[a, b, c]], closest_pair, closest_distance, joined_already) do
    IO.puts("closest")
    {closest_pair, closest_distance}
  end

  def closest_pair([[a, b, c] | tail], closest_pair, closest_distance, joined_already) do
    # IO.puts(Enum.join([a,b,c],","))
    next = Enum.at(tail, 0)

    {closest, distance} =
      closest_to_given([a, b, c], tail, next, distance([a, b, c], next), joined_already)

    # IO.puts("closest_pair")
    if distance < closest_distance do
      closest_pair(tail, [[a, b, c], closest], distance, joined_already)
    else
      closest_pair(tail, closest_pair, closest_distance, joined_already)
    end
  end

  def closest_pair([], closest_pair, closest_distance, joined_already) do
    {closest_pair, closest_distance}
  end

  def join(nums, max) do
    join(nums, to_circuits(nums), %{}, 0, max)
  end

  def join(nums, circuits, joined_already, i, max) do
    IO.puts(i)

    if i > max do
      circuits
    else
      first = Enum.at(nums, 0)
      second = Enum.at(nums, 1)

      {[a, b], distance} =
        closest_pair(nums, [first, second], distance(first, second), joined_already)

      joined_already2 = Map.put(joined_already, [a, b], true)
      joined_already2 = Map.put(joined_already2, [b, a], true)
      # IO.puts(Enum.count(circuits))
      circuits2 = move_to_circuit(a, b, circuits)
      join(nums, circuits2, joined_already2, i + 1, max)
    end
  end

  def join_no_max(nums) do
    join_no_max(nums, to_circuits(nums), %{})
  end

  def join_no_max(nums, circuits, joined_already) do
    IO.puts(Enum.count(circuits))
    first = Enum.at(nums, 0)
    second = Enum.at(nums, 1)

    {[a, b], distance} =
      closest_pair(nums, [first, second], distance(first, second), joined_already)

    IO.puts(inspect(a))
    IO.puts(inspect(b))
    joined_already2 = Map.put(joined_already, [a, b], true)
    joined_already2 = Map.put(joined_already2, [b, a], true)
    IO.puts(Map.get(joined_already2, [a, b]))
    # IO.puts(Enum.count(circuits))
    circuits2 = move_to_circuit(a, b, circuits)

    if Enum.count(circuits2) == 1 do
      [a, b]
    else
      join_no_max(nums, circuits2, joined_already2)
    end
  end

  def to_circuits(nums) do
    Enum.map(nums, fn coords -> Map.put(%{}, coords, true) end)
  end

  def move_to_circuit(first, second, full_circuits) do
    c1 = find_circuit(first, full_circuits)
    c2 = find_circuit(second, full_circuits)

    if c1 == c2 do
      IO.puts(inspect(first))
      IO.puts(inspect(second))
      IO.puts("same circuit already")
    end

    # IO.puts(inspect(full_circuits))
    new =
      Enum.reject(full_circuits, fn c -> Map.get(c, first, false) or Map.get(c, second, false) end)

    new ++ [Map.merge(c1, c2)]
  end

  def find_circuit(coords, []) do
    [coords]
  end

  def find_circuit(coords, [cur | tail]) do
    if Map.get(cur, coords, false) do
      cur
    else
      find_circuit(coords, tail)
    end
  end
end
