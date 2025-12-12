package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type shape struct {
	pieces    []string
	pieces90  []string
	pieces180 []string
	pieces270 []string
}

type field struct {
	height, width int
	frequencies   []int
}

func main() {
	f, err := os.Open("inputs/advent12.txt")
	// f, err := os.Open("inputs/advent12test.txt")
	defer f.Close()
	if err != nil {
		panic("can't open file")
	}
	builder := &strings.Builder{}
	scanner := bufio.NewScanner(f)
	shapes := make([]shape, 0)
	fields := make([]field, 0)
	for scanner.Scan() {
		txt := scanner.Text()
		if strings.Contains(txt, "x") {
			f, err := parseField(txt)
			if err != nil {
				panic("f")
			}
			fields = append(fields, f)
			continue
		}
		if strings.Trim(txt, "\r\n") == "" {
			shapes = append(shapes, parse12(builder.String()))
			builder.Reset()
		}
		builder.WriteString(scanner.Text() + "\n")
	}
	f.Close()
	fmt.Println(shapes)
	fmt.Println(fields)
	sum := 0
	for i, f := range fields {
		m := make([][]int, f.height)
		for i := range m {
			m[i] = make([]int, f.width)
		}
		fmt.Println(f, i)
		if !canFit(f, shapes) {
			fmt.Println("can't fit")
		}
		ma := make(map[[2]int]map[int]bool)
		if canFit(f, shapes) && f.try(m, f.frequencies, shapes, ma, 0) {
			fmt.Println(sum)
			sum++
		}
	}
	fmt.Println("--")
	fmt.Println(sum)
}

func parseField(str string) (field, error) {
	f := field{}
	elems := strings.Split(str, " ")
	hw := strings.Split(strings.Replace(elems[0], ":", "", -1), "x")
	h, err := strconv.Atoi(hw[0])
	if err != nil {
		return field{}, err
	}
	w, err := strconv.Atoi(hw[1])
	if err != nil {
		return field{}, err
	}
	f.height, f.width = h, w
	for _, str := range elems[1:] {
		n, err := strconv.Atoi(str)
		if err != nil {
			continue
		}
		f.frequencies = append(f.frequencies, n)
	}
	return f, nil
}

func parse12(str string) shape {
	fmt.Println(str)
	lines := strings.Split(str, "\n")
	s := shape{}
	for _, line := range lines {
		if !strings.Contains(line, "#") && !strings.Contains(line, ".") {
			continue
		}
		s.pieces = append(s.pieces, line)
	}
	s.pieces90 = rotateCW(s.pieces)
	s.pieces180 = rotateCW(s.pieces90)
	s.pieces270 = rotateCW(s.pieces180)
	return s
}

func canFit(f field, shapes []shape) bool {
	area := f.height * f.width
	s := 0
	for i, freq := range f.frequencies {
		s += shapes[i].area() * freq
	}
	return s <= area
}

func (s *shape) area() int {
	a := 0
	for _, line := range s.pieces {
		for _, char := range line {
			if char == '#' {
				a++
			}
		}
	}
	return a
}

func place(field [][]int, pieces []string, x, y int) ([][]int, bool) {
	toAdd := make([][2]int, 0)
	for i, line := range pieces {
		for j, char := range line {
			if char == '#' {
				if field[i+x][j+y] > 0 {
					return field, false
				}
				toAdd = append(toAdd, [2]int{i + x, j + y})
			}
		}
	}
	ary := make([][]int, len(field))
	for i := range ary {
		ary[i] = make([]int, len(field[i]))
		copy(ary[i], field[i])
	}
	for _, coord := range toAdd {
		ary[coord[0]][coord[1]] = 1
	}
	return ary, true
}

func (f *field) try(cur [][]int, freqsLeft []int, shapes []shape, placed map[[2]int]map[int]bool, depth int) bool {
	numLeft := 0
	for _, n := range freqsLeft {
		numLeft += n
	}
	if numLeft == 0 {
		return true
	}
	c := placed[[2]int{-1000, -1000}]
	placed[[2]int{-1000, -1000}] = make(map[int]bool)
	// fmt.Println(depth)
	for i := range len(cur) - 2 {
	inner:
		for j := range len(cur[0]) - 2 {
			if c == nil && j > 0 {
				return false
			}
			// fmt.Println(i, j)
			if cur[i][j] == 1 {
				continue
			}
			if c == nil {
				fmt.Println(i, j)
			}
			for k := range freqsLeft {
				if placed[[2]int{i, j}] != nil && placed[[2]int{i, j}][k] {
					continue inner
				}
			}
			for k, freq := range freqsLeft {
				if placed[[2]int{i, j}] != nil && placed[[2]int{i, j}][k] {
					continue
				}
				if freq > 0 {
					newFrequencies := make([]int, len(freqsLeft))
					copy(newFrequencies, freqsLeft)
					newFrequencies[k]--
					// fmt.Println(newFrequencies)
					// fmt.Println("0")

					p := copyPlaced(placed)
					if placed[[2]int{i, j}] == nil {
						p[[2]int{i, j}] = make(map[int]bool)
					}
					p[[2]int{i, j}][k] = true
					p[[2]int{-1000, -1000}] = make(map[int]bool)
					freeSquaresInSpot := 0
					for i2 := range 3 {
						for j2 := range 3 {
							if cur[i2+i][j2+j] == 0 {
								freeSquaresInSpot++
							}
						}
					}
					if freeSquaresInSpot < shapes[k].area() {
						// fmt.Println("nofit")
						continue
					}
					// p := make(map[[2]int]map[int]bool)
					if c == nil {
						fmt.Println("90")
					}
					if ary, ok := place(cur, shapes[k].pieces, i, j); ok {
						if f.try(ary, newFrequencies, shapes, p, depth+1) {
							return true
						}
						continue
					}
					if c == nil {
						fmt.Println("90")
					}
					if ary, ok := place(cur, shapes[k].pieces90, i, j); ok {
						if f.try(ary, newFrequencies, shapes, p, depth+1) {
							return true
						}
						continue
					}
					if c == nil {
						fmt.Println("180")
					}
					if ary, ok := place(cur, shapes[k].pieces180, i, j); ok {
						if f.try(ary, newFrequencies, shapes, p, depth+1) {
							return true
						}
						continue
					}
					if c == nil {
						fmt.Println("270")
					}
					if ary, ok := place(cur, shapes[k].pieces270, i, j); ok {
						if f.try(ary, newFrequencies, shapes, p, depth+1) {
							return true
						}
						continue
					}
				}
			}
		}
	}
	return false
}

func rotateCW(pieces []string) []string {
	ret := make([]string, len(pieces))
	for i := range pieces {
		for j := range len(pieces) {
			ret[j] = string(pieces[i][j]) + ret[j]
		}
	}
	return ret
}

func copyPlaced(placed map[[2]int]map[int]bool) map[[2]int]map[int]bool {
	p := make(map[[2]int]map[int]bool)
	for k, v := range placed {
		p[k] = make(map[int]bool)
		for k2, v2 := range v {
			p[k][k2] = v2
		}
	}
	return p
}
