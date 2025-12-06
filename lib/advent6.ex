defmodule Advent6 do
  def advent6 do
    case File.read("inputs/advent6.txt") do
    # case File.read("inputs/advent6test.txt") do
      {:ok, content} ->
        lines = String.split(content, "\n")
        ary = Map.to_list(to_arrays(lines))

        sum = sum(ary, 0)

        x = part_2_parse(lines)

        IO.puts(sum)
        xarys = part_2_arrays(x, [], [])


        sum = sum2(xarys, 0)
        IO.puts(sum)
    end
  end

  def sum([], sum) do
    sum
  end

  def sum([{index, subary} | tail], sum) do
    case Enum.at(subary, 0) do
      "+" ->
        sum(tail, add_sum(Enum.slice(subary, 1, Enum.count(subary) - 1), sum))

      "*" ->
        sum(tail, add_product(Enum.slice(subary, 1, Enum.count(subary) - 1), sum))

      other ->
        sum
    end
  end

  def sum2([],sum) do
    sum
  end

  def sum2([subary | tail], sum) do

    case Enum.at(subary, 0) do
      "+" ->
        s = sum2(tail, add_sum_string(Enum.slice(subary, 1, Enum.count(subary) - 1), sum))
        s

      "*" ->
        s = sum2(tail, add_product_string(Enum.slice(subary, 1, Enum.count(subary) - 1), sum, 1))
        s

      other ->
        sum2(tail,sum)
    end
  end

  def add_sum_string([], sum) do
    sum
  end

  def add_sum_string([num_string | tail], sum) do
    {num, _} = Integer.parse(num_string, 10)
    add_sum_string(tail, sum + num)
  end

  def add_product_string([], sum, product) do
    sum + product
  end

  def add_product_string([num_string | tail], sum, product) do
    {num, _} = Integer.parse(num_string, 10)
    add_product_string(tail, sum, product * num)
  end

  def add_sum([], sum) do
    sum
  end

  def add_sum([num | tail], sum) do
    add_sum(tail, sum + num)
  end

  def add_product([num | tail], sum) do
    add_product([num | tail], sum, 1)
  end

  def add_product([], sum, product) do
    sum + product
  end

  def add_product([num | tail], sum, product) do
    add_product(tail, sum, product * num)
  end

  def to_arrays(lines) do
    to_arrays(lines, %{})
  end

  def to_arrays([line | tail], map) do
    nums = String.split(line, " ", trim: true)
    m = add_to_array(nums, 0, map)
    to_arrays(tail, m)
  end

  def to_arrays([], map) do
    map
  end

  def add_to_array([], index, map) do
    map
  end

  def add_to_array([num_string | tail], index, map) do
    case Integer.parse(num_string, 10) do
      {num, _} ->
        case Map.get(map, index, :none) do
          :none ->
            add_to_array(tail, index + 1, Map.put(map, index, [num]))

          ary ->
            add_to_array(tail, index + 1, Map.put(map, index, ary ++ [num]))
        end

      :error ->
        case num_string do
          "+" ->
            add_to_array(tail, index + 1, Map.put(map, index, ["+"] ++ Map.get(map, index)))

          "*" ->
            add_to_array(tail, index + 1, Map.put(map, index, ["*"] ++ Map.get(map, index)))

          other ->
            add_to_array(tail, index + 1, map)
        end
    end
  end

  def part_2_parse(lines) do
    cls =
      Enum.map(Enum.slice(lines, 0, Enum.count(lines) - 1), fn line -> String.split(line, "") end)

    char_lists = rotate_90_counter_clockwise(cls)



    arys = part_2_arrays(char_lists, [], [])


    char_lists
  end

  def rotate_90_counter_clockwise(matrix) do
    matrix
    |> transpose()
    |> Enum.reverse()
  end

  def transpose([]), do: []
  def transpose([[] | _]), do: []

  def transpose(matrix) do
    matrix |> Enum.zip_with(& &1)
  end

  def part_2_arrays([], arys, []) do
    arys
  end

  def part_2_arrays([row | tail], arys, cur) do
    row = String.replace(to_string(row), "\r", "")
    row = String.replace(row, "\n", "")
    row = String.replace(row, " ", "")

    if String.trim(row, "\r\n ") == "" do
      part_2_arrays(tail, [cur] ++ arys, [])
    else
      row = String.trim(row, "\r\n \t")

      mul_check = String.replace(row, "*", "")
      add_check = String.replace(row, "+", "")

      if String.length(mul_check) < String.length(row) do

        case Integer.parse(mul_check, 10) do
          {num, _} ->
            part_2_arrays(tail, [["*"] ++ [Integer.to_string(num)] ++ cur] ++ arys, [])

          :error ->
            nil
        end
      else
        if String.length(add_check) < String.length(row) do
          case Integer.parse(add_check, 10) do
            {num, _} ->
              part_2_arrays(tail, [["+"] ++ [Integer.to_string(num)] ++ cur] ++ arys, [])

            :error ->
              nil
          end
        else
          case Integer.parse(row, 10) do
            :error ->
              len = String.length(row)
              operator = String.slice(row, len - 1, 1)
              num_string = String.trim(String.slice(row, 0, len - 1))

              case Integer.parse(num_string, 10) do
                :error ->
                  arys

                {num, _} ->
                  part_2_arrays(tail, [[operator] ++ [Integer.to_string(num)] ++ cur] ++ arys, [])
              end

            {num, _} ->
              part_2_arrays(tail, arys, [Integer.to_string(num)] ++ cur)
          end
        end
      end
    end
  end
end
