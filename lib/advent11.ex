defmodule Advent11 do
  def advent11 do
    case File.read("inputs/advent11.txt") do
      # case File.read("inputs/advent11test2.txt") do
      {:ok, content} ->
        lines = String.split(String.replace(content, "\r", ""), "\n")
        boxes = parse(lines)

        # for box <- boxes do
        #   IO.puts(Enum.join(box, ","))
        # end
        IO.puts(inspect(boxes))
        # IO.puts(traverse("you", Map.get(boxes, "you", %{}), 0, boxes))
        # IO.puts(traverse("svr", Map.get(boxes, "svr", %{}), 0, boxes))
        # IO.puts(traverse("fft", Map.get(boxes, "fft", %{}), 0, boxes ))
        # IO.puts(traverse("dac", Map.get(boxes, "dac", %{}), 0, boxes ))
        # IO.puts(traverse("fft", Map.get(boxes, "fft", %{}), 0, boxes ))

        IO.puts(traverse2("svr", Map.get(boxes, "svr", %{}), 0, boxes, [], %{}))

        # IO.puts(inspect(Map.get(boxes, "svr")))
    end
  end

  def parse(ary) do
    parse(ary, %{})
  end

  def parse([], m) do
    m
  end

  def parse([line | tail], m) do
    parse(tail, parse_line(line, m))
  end

  def parse_line(nil, m) do
    m
  end
  def parse_line("", m) do
    m
  end

  def parse_line(line, m) do
    nodes = String.split(line, " ")
    node = String.replace(Enum.at(nodes, 0), ":", "")
    ma = parse_children(Enum.slice(nodes, 1, Enum.count(nodes) - 1), %{})
    Map.put(m, node, ma)
  end

  def parse_children([node | tail], m) do
    parse_children(tail, Map.put(m, node, true))
  end

  def parse_children([], m) do
    m
  end

  def traverse(cur_string, cur, sum, m) do
    # IO.puts(cur_string)

    if cur_string == "out" do
      sum + 1
    else
      neighbors = Enum.map(Map.to_list(cur), fn {k, v} -> k end)
      visit_neighbors(neighbors, sum, m)
    end
  end

  def traverse2(
        cur_string,
        cur,
        sum,
        m,
        path,
        visited
      ) do
    # IO.puts(cur_string)

    if Map.get(visited, cur_string, false) do
      sum
    else
      if(cur_string == "out" and valid_path(path, false, false)) do
        IO.puts(inspect(path))
        sum + 1
      else
        if cur_string == "out" do
          # IO.puts(inspect(path))
          sum
        else
          neighbors = Enum.map(Map.to_list(cur), fn {k, v} -> k end)

          visit_neighbors2(
            neighbors,
            sum,
            m,
            path ++ [cur_string],
            visited
          )
        end
      end
    end
  end

  def valid_path([], dac_visited, fft_visited) do
    dac_visited and fft_visited
  end

  def valid_path([node | tail], dac_visited, fft_visited) do
    if node == "dac" do
      valid_path(tail, true, fft_visited)
    else
      if node == "fft" do
        valid_path(tail, dac_visited, true)
      else
        valid_path(tail, dac_visited, fft_visited)
      end
    end
  end

  def visit_neighbors([], sum, m) do
    sum
  end

  def visit_neighbors([neighbor | tail], sum, m) do
    visit_neighbors(
      tail,
      traverse(neighbor, Map.get(m, neighbor, %{}), sum, m),
      m
    )
  end

  def visit_neighbors2([], sum, m, path, visited) do
    sum
  end

  def visit_neighbors2([neighbor | tail], sum, m, path, visited) do
    visit_neighbors2(
      tail,
      traverse2(neighbor, Map.get(m, neighbor, %{}), sum, m, path, visited),
      m,
      path,
      visited
    )
  end
end
