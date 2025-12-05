defmodule Advent5 do
  def advent5 do
    case File.read("inputs/advent5.txt") do
    # case File.read("inputs/advent5test.txt") do
      {:ok, content} ->
        content = String.replace(content, "\r", "")
        [first, second] = String.split(content, "\n\n")
        lines = String.split(first, "\n")
        m = ranges(lines, %{})
        ary = Map.to_list(m)
        nums = to_nums(String.split(second, "\n"))

        count = check(ary, nums)
        IO.puts(count)

        x = keep_reducing(ary)

        for {[l, h], _} <- x do
          IO.puts(Integer.to_string(l) <> "," <> Integer.to_string(h))
        end

        IO.puts(Enum.count(x))
        IO.puts(count_ranges(x, 0))
    end
  end

  def keep_reducing(ary) do
    reduced = insert_into_reduced(ary,[],[])
    if Enum.count(reduced) < Enum.count(ary) do
      keep_reducing(reduced)
    else
      reduced
    end
  end

  def count_ranges([{[cur_low, cur_high], _} | tail], sum) do
    count_ranges(tail, sum + (cur_high - cur_low + 1))
  end

  def count_ranges([], sum) do
    sum
  end

  def ranges([], map) do
    map
  end

  def ranges([head | tail], map) do
    {dash_index, _} = :binary.match(head, "-")
    pre = String.slice(head, 0, dash_index)
    post = String.slice(head, dash_index + 1, String.length(head) - dash_index)
    {preNum, _} = Integer.parse(pre, 10)
    {postNum, _} = Integer.parse(post, 10)
    ranges(tail, Map.put(map, [preNum, postNum], true))
  end

  def to_nums([], nums) do
    nums
  end

  def to_nums([head | tail], nums) do
    case Integer.parse(head, 10) do
      {num, _} ->
        IO.puts(num)
        to_nums(tail, nums ++ [num])

      :error ->
        to_nums(tail, nums)
    end
  end

  def to_nums(ary) do
    to_nums(ary, [])
  end

  def check(ary, nums) do
    check(ary, nums, 0, ary)
  end

  def check(ary, [], count, full_ary) do
    count
  end

  def check([{[small, large], _} | t1], [h2 | t2], count, full_ary) do
    if h2 >= small and h2 <= large do
      check(full_ary, t2, count + 1, full_ary)
    else
      check(t1, [h2 | t2], count, full_ary)
    end
  end

  def check([], [h2 | t2], count, full_ary) do
    check(full_ary, t2, count, full_ary)
  end

  def reduce(_, [], map) do
    {map, false}
  end

  def insert_into_reduced(
        [{[cur_low, cur_high], v} | ary_tail],
        [{[check_low, check_high], _} | tail],
        reduced
      ) do
    # remove [check_low,check_high]
    IO.puts(
      Integer.to_string(cur_low) <>
        "," <>
        Integer.to_string(cur_high) <>
        "vs" <> Integer.to_string(check_low) <> "," <> Integer.to_string(check_high)
    )

    if cur_low <= check_low and cur_high >= check_high do
      reduced2 =
        Enum.map(reduced, fn
          x when x =={[check_low, check_high],v} ->{[cur_low, cur_high],v}
          x -> x
        end)

      insert_into_reduced(ary_tail, reduced2, reduced2)
    else
      # remove [cur_low,cur_high]
      if cur_low >= check_low and cur_high <= check_high do
        insert_into_reduced(ary_tail, reduced, reduced)
      else
        # combine into [cur_low,check_high]
        if cur_low <= check_low and cur_high >= check_low and cur_high <= check_high do
          reduced2 =
            Enum.map(reduced, fn
              x when x == {[check_low, check_high],v} ->{[cur_low, check_high],v}
              x -> x
            end)

          insert_into_reduced(ary_tail, reduced2, reduced2)
        else
          # combine into check_low,cur_high
          if cur_low >= check_low and check_high >= cur_low and cur_high >= check_high do
            reduced2 =
              Enum.map(reduced, fn
                x when x == {[check_low, check_high], v} ->
                  {[check_low, cur_high], v}

                x ->
                  x
              end)

            insert_into_reduced(ary_tail, reduced2, reduced2)
          else
            # do nothing
            insert_into_reduced([{[cur_low, cur_high], v} | ary_tail], tail, reduced)
          end
        end
      end
    end
  end

  def insert_into_reduced(
        [{[cur_low, cur_high], v} | tail],
        [],
        reduced
      ) do
    reduced = reduced ++ [{[cur_low, cur_high], v}]
    insert_into_reduced(tail, reduced, reduced)
  end

  def insert_into_reduced([cur_low, cur_high], [], reduced) do
    reduced ++ [[cur_low, cur_high]]
  end

  def insert_into_reduced([], reduced, reduced2) do
    reduced2
  end
end
