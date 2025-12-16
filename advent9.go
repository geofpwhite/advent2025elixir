package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type path struct {
	x, y int
}

type paths []path

type direction int

const (
	U direction = iota + 1
	D
	L
	R
)

func main() {
	f, err := os.Open("inputs/advent9.txt")
	// f, err := os.Open("inputs/advent9test.txt")
	if err != nil {
		panic("can't open file")
	}
	defer f.Close()
	scanner := bufio.NewScanner(f)
	paths := make(paths, 0)
	for scanner.Scan() {
		p, err := parse9(scanner.Text())
		if err != nil {
			continue
		}
		paths = append(paths, p)
	}
	f.Close()
	fmt.Println(paths)
	paths = append(paths, paths[0])
	largest := 0
	var lp1, lp2 path
	for i, p := range paths {
		// fmt.Println(p)
	inner:
		for _, p2 := range paths[i+1:] {
			v := vertices(p, p2)
			for i := range 4 {
				c1, c2 := v[i], v[(i+1)%4]
				if paths.intersects(c1, c2) {
					// fmt.Println(p, p2, "invalid")
					continue inner
				}
				var dx, dy int
				switch {
				case c1.x > c2.x:
					dx = -1
				case c1.x < c2.x:
					dx = 1
				case c1.y > c2.y:
					dy = -1
				case c1.y < c2.y:
					dy = 1
				}
				for c1 != c2 {
					c1.x += dx
					c1.y += dy
					if !paths.inside(c1.x, c1.y) {
						// fmt.Println(p, p2, "invalid,", c1, "not in shape")
						continue inner
					}
				}
			}
			avgX := (p.x + p2.x) / 2
			avgY := (p.y + p2.y) / 2
			if paths.inside(avgX, avgY) && paths.inside(p.x, avgY) && paths.inside(avgX, p.y) && paths.inside(p2.x, avgY) && paths.inside(avgX, p2.y) {
				a := area(p, p2)
				if a > largest {
					largest = a
					lp1, lp2 = p, p2
				}
			}
		}
		fmt.Println(p, i, largest, lp1, lp2)
	}
	fmt.Println(largest, lp1, lp2)
	fmt.Println(paths.inside(8, 4))
	fmt.Println(paths.inside(9, 5))
	fmt.Println(paths.inside(9, 6))
}

func area(p1, p2 path) int {
	return (1 + max(p1.x-p2.x, p2.x-p1.x)) * (1 + max(p1.y-p2.y, p2.y-p1.y))
}

func vertices(p1, p2 path) [4]path {
	b1 := path{p1.x, p2.y}
	b2 := path{p2.x, p1.y}
	return [4]path{p1, b1, p2, b2}
}

func (p paths) intersects(p1, p2 path) bool {
	for i, path := range p[:len(p)-1] {
		pNext := p[i+1]
		if lineIntersect(p1, p2, path, pNext) {
			// fmt.Println(p1, p2, "intersects with", path, pNext)
			return true
		}
	}

	return false
}

func lineIntersect(p11, p12, p21, p22 path) bool {
	return ((p11.x == p12.x && p21.y == p22.y) &&
		(((p11.y > p21.y && p12.y < p22.y) ||
			(p11.y < p21.y && p12.y > p22.y)) &&
			((p11.x < p21.x && p11.x > p22.x) || (p11.x > p21.x && p11.x < p22.x)))) ||

		((p11.y == p12.y && p21.x == p22.x) &&
			(((p11.x > p21.x && p12.x < p22.x) ||
				(p11.x < p21.x && p12.x > p22.x)) &&
				((p11.y < p21.y && p11.y > p22.y) || (p11.y > p21.y && p11.y < p22.y))))
}

func parse9(line string) (path, error) {
	strs := strings.Split(line, ",")
	f, err := strconv.Atoi(strs[0])
	if err != nil {
		return path{}, err
	}
	s, err := strconv.Atoi(strs[1])
	if err != nil {
		return path{}, err
	}
	return path{
		x: f,
		y: s,
	}, nil
}

var insides = make(map[[2]int]bool)

func (paths paths) inside(x, y int) bool {
	if inside, ok := insides[[2]int{x, y}]; ok {
		return inside
	}
	var curDir, LorR direction

	turns := 0
	for i, p := range paths[:len(paths)-1] {
		pNext := paths[i+1]
		if (p.x == x && p.y == y) || (pNext.x == x && pNext.y == y) {
			insides[[2]int{x, y}] = true
			return true
		}
		dir := movementDirection(p.x, p.y, pNext.x, pNext.y)
		switch curDir {
		case U:
			switch dir {
			case L:
				turns--
			case R:
				turns++
			}
		case D:
			switch dir {
			case L:
				turns++
			case R:
				turns--
			}
		case L:
			switch dir {
			case U:
				turns++
			case D:
				turns--
			}
		case R:
			switch dir {
			case U:
				turns--
			case D:
				turns++
			}
		}
		curDir = dir
		if dir2, btwn := between(p, pNext, path{x, y}); btwn {
			if dir2 == 0 {
				// fmt.Println("on", p, pNext, x, y)
				insides[[2]int{x, y}] = true
				return true
			}
			LorR = dir2
		}
	}
	// fmt.Println(LorR, x, y, turns)
	insides[[2]int{x, y}] = (turns > 0 && LorR == L) || (turns < 0 && LorR == R)
	return insides[[2]int{x, y}]
}

func between(first, second, point path) (direction, bool) {
	dir := movementDirection(first.x, first.y, second.x, second.y)
	switch {
	case first.y == second.y && ((second.x <= point.x && point.x <= first.x) || (first.x <= point.x && point.x <= second.x)):
		if first.y > point.y {
			switch dir {
			case L:
				return L, true
			case R:
				return R, true
			}
		}
		if first.y < point.y {
			switch dir {
			case R:
				return L, true
			case L:
				return R, true
			}
		}
		return 0, true
	case first.x == second.x && ((second.y <= point.y && point.y <= first.y) || (first.y <= point.y && point.y <= second.y)):
		if first.x > point.x {
			switch dir {
			case U:
				return R, true

			case D:
				return L, true
			}
		}
		if first.x < point.x {
			switch dir {
			case U:
				return L, true

			case D:
				return R, true
			}
		}
		return 0, true
	}
	return 0, false
}

func movementDirection(x1, y1, x2, y2 int) direction {
	if x1 == x2 {
		if y1 > y2 {
			return U
		}
		return D
	}
	if x1 > x2 {
		return L
	}
	return R
}
