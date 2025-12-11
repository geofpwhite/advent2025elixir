defmodule Advent9 do
  def advent9 do
    case File.read("inputs/advent9.txt") do
    # case File.read("inputs/advent9test.txt") do
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
        a = all_areas(boxes, Enum.slice(boxes, 1, Enum.count(boxes) - 1), 0)
        IO.puts(inspect(a))

        # boxes = boxes ++ [Enum.at(boxes, 0)]

        {best_area, [[x1, y1], [x2, y2]]} =
          best_legal_area(boxes, Enum.slice(boxes, 1, Enum.count(boxes) - 1), 0, boxes, [
            [0, 0],
            [0, 0]
          ])

        IO.puts(best_area)

        IO.puts(
          to_string(x1) <> "," <> to_string(y1) <> "-" <> to_string(x2) <> "," <> to_string(y2)
        )

        # IO.puts("---------")
        # x = legal?([9, 5], [2, 3], boxes)
        # IO.puts(x)
        # IO.puts(best_area)
        IO.puts(path_contains_point?([5, 4], boxes))
        IO.puts(path_contains_point?([5, 6], boxes))
        IO.puts(path_contains_point?([20, 20], boxes))
        IO.puts(path_contains_point?([20, 5], boxes))
        # IO.puts(path_contains_point?([98280,], boxes))
        IO.puts(path_contains_point?([12, 8], boxes))
        IO.puts(path_contains_point?([12, 8], boxes))
        # IO.puts(legal?([83801,85151],[14657,16483],boxes))
        IO.puts(best_area)
        boxes = Enum.reverse(boxes)
        IO.puts(inspect(
          best_legal_area(boxes, Enum.slice(boxes, 1, Enum.count(boxes) - 1), 0, boxes, [
            [0, 0],
            [0, 0]
          ])))
          IO.puts(best_area)
    end
  end

  def parse(lines) do
    parse(lines, [])
  end

  def parse([], points) do
    points
  end

  def parse([line | rest], points) do
    line = String.trim(line, "\t\r\n")

    if line == "" do
      parse(rest, points)
    else
      [ns1, ns2] = String.split(line, ",")
      {n1, _} = Integer.parse(ns1, 10)
      {n2, _} = Integer.parse(ns2, 10)
      parse(rest, points ++ [[n1, n2]])
    end
  end

  def area([x1, y1], [x2, y2]) do
    abs(x2 - x1) * abs(y2 - y1) + (abs(x2 - x1) + abs(y2 - y1) + 1)
  end

  def all_areas([[x, y] | tail1], [cur | tail2], largest) do
    a = area([x, y], cur)

    if a > largest do
      all_areas([[x, y] | tail1], tail2, a)
    else
      all_areas([[x, y] | tail1], tail2, largest)
    end
  end

  def all_areas([[x, y]], [], largest) do
    largest
  end

  def all_areas([[x, y] | tail1], [], largest) do
    all_areas(tail1, Enum.slice(tail1, 1, Enum.count(tail1) - 1), largest)
  end

  def best_legal_area([[x, y]], [], largest, points, [[lx1, ly1], [lx2, ly2]]) do
    {largest, [[lx1, ly1], [lx2, ly2]]}
  end

  def best_legal_area([[x, y] | tail1], [], largest, points, [[lx1, ly1], [lx2, ly2]]) do
    best_legal_area(tail1, Enum.slice(tail1, 1, Enum.count(tail1) - 1), largest, points, [
      [lx1, ly1],
      [lx2, ly2]
    ])
  end

  def best_legal_area([[x, y] | tail1], [cur | tail2], largest, points, [[lx1, ly1], [lx2, ly2]]) do
    a = area([x, y], cur)

    if a > largest and legal?([x, y], cur, points) do
      best_legal_area([[x, y] | tail1], tail2, a, points, [[x, y], cur])
    else
      best_legal_area([[x, y] | tail1], tail2, largest, points, [[lx1, ly1], [lx2, ly2]])
    end
  end

  def legal?([x1, y1], [x2, y2], points) do
    intersections = [
      [
        [x1, y1],
        [x1, y2]
      ],
      [
        [x1, y2],
        [x2, y2]
      ],
      [
        [x2, y2],
        [x2, y1]
      ],
      [
        [x2, y1],
        [x1, y1]
      ]
    ]

    if !all_intersects_safe?(intersections, points) do
      # IO.puts("not safe")
      false
    else
      # path_contains_point?(
      #   [
      #     Integer.floor_div(x1 + x2, 2),
      #     Integer.floor_div(y1 + y2, 2)
      #   ],
      #   points
      # ) and
        perimeter_contained?(intersections, points)
    end
  end

  def perimeter_contained?([[[x1, y1], [x2, y2]]], points) do
    if x2 == x1 do
      vertices = path_contains_point?([x1, y1], points) and path_contains_point?([x2, y2], points)

      p = path_contains_point?([x1, Integer.floor_div(y1 + y2, 2)], points)
      vertices and p
    else
      vertices = path_contains_point?([x1, y1], points) and path_contains_point?([x2, y2], points)

      p = path_contains_point?([x1, Integer.floor_div(y1 + y2, 2)], points)
      vertices and p
    end
  end

  def perimeter_contained?([[[x1, y1], [x2, y2]] | tail], points) do
    if x2 == x1 do
      vert1 = path_contains_point?([x1, y1], points)
      vert2 = path_contains_point?([x2, y2], points)
      v2 = path_contains_point?([x1, Integer.floor_div(y1 + y2, 2)], points)
      pc = perimeter_contained?(tail, points)
      # IO.puts(inspect([vert1, vert2, v2, pc, [x1, y1], [x2, y2]]))
      vert1 and vert2 and v2 and pc
    else
      vert1 = path_contains_point?([x1, y1], points)
      vert2 = path_contains_point?([x2, y2], points)
      v2 = path_contains_point?([Integer.floor_div(x1 + x2, 2), y1], points)
      pc = perimeter_contained?(tail, points)
      # IO.puts(inspect([vert1, vert2, v2, pc, [x1, y1], [x2, y2]]))

      vert1 and vert2 and v2 and pc
    end
  end

  def all_intersects_safe?([], _) do
    true
  end

  def all_intersects_safe?([[[x1, y1], [x2, y2]] | tail], points) do
    if intersects?([[x1, y1], [x2, y2]], points, points) do
      false
    else
      all_intersects_safe?(tail, points)
    end
  end

  def turn_direction(prev, cur) do
    case prev do
      0 ->
        case cur do
          2 ->
            -1

          3 ->
            1
        end

      1 ->
        case cur do
          2 -> 1
          3 -> -1
        end

      2 ->
        case cur do
          0 -> 1
          1 -> -1
        end

      3 ->
        case cur do
          0 -> -1
          1 -> 1
        end
    end
  end

  def path_contains_point?(
        [px, py],
        [[cx1, cy1]],
        direction,
        turns,
        direction_to_point,
        crossed_x,
        crossed_y,
        prev_cross
      ) do
    IO.puts(
      inspect([[px, py], [cx1, cy1], direction, turns, direction_to_point, crossed_x, crossed_y])
    )

    crossed_x and crossed_y and
      ((turns < 0 and not direction_to_point) or (turns > 0 and direction_to_point))
  end

  def path_contains_point?(
        [px, py],
        [[cx1, cy1], [cx2, cy2] | tail]
      ) do
    d = direction([cx1, cy1], [cx2, cy2])

    if (px == cx1 and py == cy1) or (px == cx2 and py == cy2) do
      # point is one of the vertices
      true
    else
      if (((cx1 < px and px < cx2) or (cx2 < px and px < cx1)) and cy1 == py and cy2 == py) or
           (((cy2 < py and py < cy1) or (cy1 < py and py < cy2)) and cx1 == px and cx2 == px) do
        #  IO.puts("it's here")
        true
      else
        if (cx1 < px and px < cx2) or (cx1 > px and px > cx2) do
          direction_to_point = direction_to_point([cx1, cy1], [cx2, cy2], [px, py])

          path_contains_point?(
            [px, py],
            [[cx2, cy2] | tail],
            d,
            0,
            direction_to_point,
            false,
            true,
            false
          )
        else
          if (cy1 > py and py > cy2) or (cy1 < py and cy2 > py) do
            # we went past the point, need to update direction_to_point
            direction_to_point = direction_to_point([cx1, cy1], [cx2, cy2], [px, py])
            path_contains_point?(
              [px, py],
              [[cx2, cy2] | tail],
              d,
              0,
              direction_to_point,
              true,
              false,false
            )
          else
            path_contains_point?(
              [px, py],
              [[cx2, cy2] | tail],
              d,
              0,
              false,
              false,
              false,false
            )
          end
        end
      end
    end
  end

  def path_contains_point?(
        [px, py],
        [[cx1, cy1], [cx2, cy2] | tail],
        direction,
        turns,
        direction_to_point,
        crossed_x,
        crossed_y,
        prev_cross
      ) do
    # direction_to_point is false for left and true for right
    # turns is negative if going left and positive if going right
    new_direction = direction([cx1, cy1], [cx2, cy2])
    turns = turns + turn_direction(direction, new_direction)
    # IO.puts(turns)

    if (px == cx1 and py == cy1) or (px == cx2 and py == cy2) do
      # point is on of the vertices
      IO.puts(298)
      true
    else
      if (px == cx1 and px == cx2 and ((cy1 <= py and py <= cy2) or (cy2 <= py and py <= cy1))) or
           (py == cy1 and py == cy2 and ((cx1 <= px and px <= cx2) or (cx2 <= px and px <= cx1))) do
        IO.puts(303)
        true
      else
        if (cy2 < py and py < cy1) or (cy1 < py and py < cy2) do
          direction_to_point2 = direction_to_point([cx1, cy1], [cx2, cy2], [px, py])

          if prev_cross do
            path_contains_point?(
              [px, py],
              [[cx2, cy2] | tail],
              new_direction,
              turns,
              direction_to_point2,
              true,
              crossed_y,
              false
            )
          else
            path_contains_point?(
              [px, py],
              [[cx2, cy2] | tail],
              new_direction,
              turns,
              direction_to_point,
              true,
              crossed_y,
              prev_cross
            )
          end
        else
          if (cx1 < px and px < cx2) or (cx2 < px and px < cx1) do
            # we went past the point, need to update direction_to_point
            direction_to_point2 = direction_to_point([cx1, cy1], [cx2, cy2], [px, py])

            # IO.puts "new relative " <> inspect(direction_to_point) <> inspect([[cx1, cy1], [cx2, cy2], [px, py]])
            if not prev_cross do
              path_contains_point?(
                [px, py],
                [[cx2, cy2] | tail],
                new_direction,
                turns,
                direction_to_point2,
                crossed_x,
                true,
                true
              )
            else
              path_contains_point?(
                [px, py],
                [[cx2, cy2] | tail],
                new_direction,
                turns,
                direction_to_point,
                crossed_x,
                true,
                prev_cross
              )
            end
          else
            path_contains_point?(
              [px, py],
              [[cx2, cy2] | tail],
              new_direction,
              turns,
              direction_to_point,
              crossed_x,
              crossed_y,
              prev_cross
            )
          end
        end
      end
    end
  end

  def direction_to_point([lx1, ly1], [lx2, ly2], [px, py]) do
    if px > lx1 and px < lx2 do
      if py > ly1 do
        # on the left
        IO.puts(1)
        false
      else
        IO.puts(1)
        true
      end
    else
      if px < lx1 and px > lx2 do
        if py > ly1 do
          IO.puts(2)
          true
        else
          IO.puts(2)
          false
        end
      else
        if py > ly1 and py < ly2 do
          IO.puts(3)

          if px > lx1 do
            false
          else
            true
          end
        else
          IO.puts(4)

          if px > lx1 do
            true
          else
            false
          end
        end
      end
    end
  end

  def direction([cx1, cy1], [cx2, cy2]) do
    if cx2 - cx1 > 0 do
      # +x
      0
    else
      if cx2 - cx1 < 0 do
        # -x
        1
      else
        if cy2 - cy1 > 0 do
          # +y
          2
        else
          # -y
          3
        end
      end
    end
  end

  def intersects?([[lx1, ly1], [lx2, ly2]], [[cx1, cy1]], points) do
    false
  end

  def intersects?([[lx1, ly1], [lx2, ly2]], [[cx1, cy1], [cx2, cy2] | tail], points) do
    # if (lx1 == cx1 and ly1 == cy1) or (lx1 == cx2 and ly2 == cy2) or (lx2 == cx2 and ly2 == cy2) or (lx2 == cx1 and ly2 ==cy1) do
    # true
    # else
    minlx = min(lx1, lx2)
    minly = min(ly1, ly2)
    maxlx = max(lx1, lx2)
    maxly = max(ly1, ly2)
    mincx = min(cx1, cx2)
    mincy = min(cy1, cy2)
    maxcx = max(cx1, cx2)
    maxcy = max(cy1, cy2)

    if (lx1 == lx2 and cx1 == cx2) or (ly1 == ly2 and cy1 == cy2) do
      # parallel

      if lx1 == lx2 and cx1 == cx2 do
        # both are vertical, check if on same axis and for overlap
        if lx1 == cx1 do
          if mincy <= minly and maxcy >= maxly do
            # l is inside of c line
            intersects?([[lx1, ly1], [lx2, ly2]], [[cx2, cy2] | tail], points)
          else
            path_contains_point?([lx1, ly1], points) and
              path_contains_point?([lx2, ly2], points) and
              intersects?([[lx1, ly1], [lx2, ly2]], [[cx2, cy2] | tail], points)
          end
        else
          intersects?([[lx1, ly1], [lx2, ly2]], [[cx2, cy2] | tail], points)
        end
      else
        if ly1 == cy1 do
          if mincx <= minlx and maxcx >= maxlx do
            # l is inside of c line
            intersects?([[lx1, ly1], [lx2, ly2]], [[cx2, cy2] | tail], points)
          else
            path_contains_point?([lx1, ly1], points) and
              path_contains_point?([lx2, ly2], points) and
              intersects?([[lx1, ly1], [lx2, ly2]], [[cx2, cy2] | tail], points)
          end
        else
          intersects?([[lx1, ly1], [lx2, ly2]], [[cx2, cy2] | tail], points)
        end
      end

      # if lx1 == cx1 or ly1 == cy1 do
      # path_contains_point?([lx1, ly1], points) and
      #   path_contains_point?([lx2, ly2], points) and
      #   intersects?([[lx1, ly1], [lx2, ly2]], [[cx2, cy2] | tail], points)
      # else
      #   intersects?([[lx1, ly1], [lx2, ly2]], [[cx2, cy2] | tail], points)
      # end
    else
      if lx1 == lx2 do
        # line is vertical
        if mincx <= lx1 and maxcx >= lx1 and minly < cy1 and maxly > cy1 do
          if mincx == lx1 or maxcx == lx1 do
            if path_contains_point?([lx1, ly1], points) and
                 path_contains_point?([lx2, ly2], points) do
              intersects?([[lx1, ly1], [lx2, ly2]], [[cx2, cy2] | tail], points)
            else
              true
            end
          else
            true
          end
        else
          intersects?([[lx1, ly1], [lx2, ly2]], [[cx2, cy2] | tail], points)
        end
      else
        # line is horizontal
        if mincy <= ly1 and maxcy >= ly1 and minlx < cx1 and maxlx > cx1 do
          if mincy == ly1 or maxcy == ly1 do
            path_contains_point?([lx1, ly1], points) and path_contains_point?([lx2, ly2], points) and
              intersects?([[lx1, ly1], [lx2, ly2]], [[cx2, cy2] | tail], points)
          else
            true
          end
        else
          intersects?([[lx1, ly1], [lx2, ly2]], [[cx2, cy2] | tail], points)
        end
      end
    end
  end
end
