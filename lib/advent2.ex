defmodule Advent2 do
  def advent2 do
    case File.read("inputs/advent2.txt") do
      # case File.read("inputs/advent1test.txt") do
      {:ok, content} ->
        content = String.replace(content, "\r", "")
        lines = String.split(content, ",")
        num = invalid_in_range(lines)

        IO.puts(num)
    end
  end

  def invalid_in_range([head | tail]) do
    [first, second] = String.split(head, "-")
    {num1, _} = Integer.parse(first, 10)
    {num2, _} = Integer.parse(second, 10)
    # IO.puts(num1)
    invalid_in_range(0, num1, num2, tail)
  end

  def invalid_in_range(cur_sum, cur_num, max, []) do
    cur_sum = cur_sum + check_2(cur_num)

    if cur_num == max do
      cur_sum
    else
      invalid_in_range(cur_sum, cur_num + 1, max, [])
    end
  end

  def invalid_in_range(cur_sum, cur_num, max, [head | tail]) do
    # IO.puts(x)
    cur_sum = cur_sum + check_2(cur_num)

    if cur_num == max do
      [first, second] = String.split(head, "-")
      {num1, _} = Integer.parse(first, 10)
      {num2, _} = Integer.parse(second, 10)
      # IO.puts(num1)
      invalid_in_range(cur_sum, num1, num2, tail)
    else
      invalid_in_range(cur_sum, cur_num + 1, max, [head | tail])
    end
  end

  def check(num) do
    str = Integer.to_string(num)
    {first, second} = String.split_at(str, Integer.floor_div(String.length(str), 2))

    if first == second do
      num
    else
      0
    end
  end

  def check(num_string, substring_length) do
    str = String.slice(num_string, 0, substring_length)
    # IO.puts(str<>" str")
    {first, second} = String.split_at(num_string, substring_length)
    is_repeating(str, first,second)
  end

  @spec is_repeating(any(), any(), any()) :: boolean()
  def is_repeating(pattern, sub,"") do

    pattern == sub
  end
  def is_repeating(pattern,"","") do
    true
  end

  def is_repeating(pattern, sub,rest) do
    # IO.puts(pattern<>","<>sub)
    # IO.puts(tail)
    if pattern != sub do
      false
    else
      {next, rest} = String.split_at(rest,String.length(pattern))
      is_repeating(pattern,next,rest)
    end
  end

  def check_2(num) do
    str = Integer.to_string(num)
    factors = factors(String.length(str), 1, [])

    if check_factors(str, factors) do
      num
    else
      0
    end
  end

  def check_factors(num_string, [factor | tail]) do
    if check(num_string, factor) do
      true
    else
    check_factors(num_string, tail)
    end

  end

  def check_factors(num_string, []) do
    false
  end

  def factors(length, num, cur_factors) do
    if num > Integer.floor_div(length, 2) do
      cur_factors
    else
      if Integer.mod(length, num) == 0 do
        # IO.puts("divisible")
        factors(length, num + 1, cur_factors ++ [num])
      else
        factors(length, num + 1, cur_factors)
      end
    end
  end
end
