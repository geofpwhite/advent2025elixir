defmodule Advent3 do
  def advent3 do
    case File.read("inputs/advent3.txt") do
    # case File.read("inputs/advent3test.txt") do
      {:ok, content} ->
        content = String.replace(content, "\r", "")
        lines = String.split(content, "\n")

        sum = sum(lines, 0)
        sum2 = sum_2(lines, 0)
        IO.puts(sum)
        IO.puts(sum2)
    end
  end

  def sum([line | tail], cur_sum) do
    sum(tail, cur_sum + largest_two_digits(line, 0, 0))
  end

  def sum([], cur_sum) do
    cur_sum
  end

  def sum_2([], cur_sum) do
    cur_sum
  end

  def sum_2([""], cur_sum) do
    cur_sum
  end

  def sum_2([line | tail], cur_sum) do
    start = String.slice(line, String.length(line) - 12, 12)
    next = String.slice(line, 0, String.length(line) - 12)
    sum_2(tail, cur_sum + largest_twelve_digits(next, start))
  end

  def largest_two_digits("", largest_first, largest_second) do
    largest_first * 10 + largest_second
  end

  def largest_two_digits(num_string, largest_first, largest_second) do
    case Integer.parse(String.slice(num_string, 0, 1), 10) do
      {num, _} ->
        next = String.slice(num_string, 1, String.length(num_string))

        if num > largest_first and next != "" do
          largest_two_digits(next, num, 0)
        else
          if num > largest_second do
            largest_two_digits(next, largest_first, num)
          else
            largest_two_digits(next, largest_first, largest_second)
          end
        end

      :error ->
        largest_first * 10 + largest_second
    end
  end

  def largest_twelve_digits("", cur_num) do
    case Integer.parse(cur_num,10) do
      {num,_}->
        num
      :error->
        -1
    end
  end

  def largest_twelve_digits(num_string, cur_num) do
    len = String.length(num_string)
    new_digit = String.slice(num_string, len - 1, 1)
    {best, _} = Integer.parse(cur_num, 10)
    x = best(cur_num, new_digit, 0, best)
    largest_twelve_digits(String.slice(num_string, 0, String.length(num_string) - 1),Integer.to_string(x))
  end

  def best(num_string, new_digit, 11, best) do
    check = replace(num_string, new_digit, 11)
    case Integer.parse(check, 10) do
      {num, _} ->
        if num > best do
          num
        else
          best
        end
      :error ->
        best
    end
  end

  def best(num_string, new_digit, i, best) do
    check = replace(num_string, new_digit, i)

    case Integer.parse(check, 10) do
      {num, _} ->
        if num > best do
          best(num_string, new_digit, i + 1, num)
        else
          best(num_string, new_digit, i + 1, best)
        end
      :error ->
        best
    end
  end

  def replace(num_string, new_digit_string, index_to_remove) do
    new_digit_string <>
      String.slice(num_string, 0, index_to_remove) <>
      String.slice(num_string, index_to_remove + 1, 12 - index_to_remove)
  end
end
