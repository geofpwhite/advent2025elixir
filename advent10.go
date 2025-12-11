package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"

	"gonum.org/v1/gonum/mat"
)

type machine struct {
	wanted   []int
	buttons  [][]int
	joltages []int
}

func main() {
	// f, err := os.Open("inputs/advent10.txt")
	f, err := os.Open("inputs/advent10test.txt")
	if err != nil {
		panic("no file")
	}
	scanner := bufio.NewScanner(f)
	machines := make([]machine, 0)
	for scanner.Scan() {
		machines = append(machines, parse(scanner.Text()))
	}
	f.Close()
	// fmt.Println(machines)
	presses := 0
	// for i, m := range machines {
	// 	fbp := fewestButtonPresses(m)
	// 	fmt.Println(i, fbp)
	// 	presses += fbp
	// }
	// fmt.Println(presses)
	presses = 0
	fmt.Println(machines)
	for i, m := range machines {
		fbp := fewestButtonPresses2(m)
		fmt.Println(i, fbp)
		presses += fbp
	}
	fmt.Println(presses)
}

type queueNode struct {
	lights  []int
	pressed int
}

func fewestButtonPresses(m machine) int {
	cur := queueNode{}
	queue := []queueNode{cur}
	for len(queue) > 0 {
		cur, queue = queue[0], queue[1:]
		if slices.Equal(cur.lights, m.wanted) {
			// fmt.Println(queue)
			return cur.pressed
		}
		for _, b := range m.buttons {
			if slices.Equal(b, cur.lights) {
				continue
			}
			queue = append(queue, queueNode{merge(cur.lights, b), cur.pressed + 1})
		}
	}
	return -1
}

type queueNode2 struct {
	joltages []int
	score    int
	pressed  int
}

func fewestButtonPresses2(m machine) int {
	var d mat.Dense
	m2, v := m.toMatrix()
	sol := d.Solve(m2, v)
	fmt.Println(d, m2)

	fmt.Println(sol)
	fmt.Println(d.RawMatrix().Data)
	return 0
	cur := queueNode2{joltages: make([]int, len(m.joltages))}
	queue := heap{cur}
	visited := make(map[string]int)

	for _, b := range m.buttons {
		nj := newJoltage(cur.joltages, b)
		queue = append(queue, queueNode2{nj, m.score(nj), 1})
	}
	slices.SortFunc(m.buttons, func(a, b []int) int { return len(b) - len(a) })
	for len(queue) > 0 {
		// cur = queue.pop()
		cur, queue = queue[0], queue[1:]
		// fmt.Println(cur.joltages)
		// fmt.Println(len(queue), len(visited), cur.joltages)
		joltageString := String(cur.joltages)
		bestYet := visited[joltageString]
		if bestYet != 0 && bestYet < cur.pressed {
			continue
		}
		if !isValid(cur.joltages, m.joltages) {
			continue
		}
		// if bestYet == 0 || bestYet > cur.pressed {
		visited[joltageString] = cur.pressed
		// }
		// fmt.Println(len(queue))
	outer:
		for _, b := range m.buttons {
			for _, num := range b {
				if cur.joltages[num] > m.joltages[num] {
					continue outer
				}
			}
			// nj := newJoltage(cur.joltages, b)
			nj, toAdd := m.untilStopped(cur.joltages, b)

			if toAdd <= 0 {
				// fmt.Println("cont")
				// for _, b := range m.buttons {

				// }

				continue
			}
			// fmt.Println(nj)

			// fmt.Println(nj)
			score := m.score(nj)
			// if score == 0 {
			// 	fmt.Println("zero fer", nj)
			// 	// return cur.pressed + toAdd
			// 	// continue
			// }
			// fmt.Println(nj, score)
			queue = append(queue, queueNode2{nj, score, cur.pressed + toAdd})
			// queue.insert(queueNode2{nj, score, cur.pressed + toAdd})

			// x := newJoltage(cur.joltages, b)
			// if isValid(x, m.joltages) {
			// 	queue = append(queue, queueNode2{x, m.score(x), cur.pressed + 1})
			// }
			// // queue.insert(queueNode2{x, m.score(x), cur.pressed + 1})
		}
	}
	return visited[String(m.joltages)]
}

func String(ary []int) string {
	b := strings.Builder{}
	for _, num := range ary {
		b.WriteString(strconv.Itoa(num) + ",")
	}
	str := b.String()
	return str[:len(str)-1]
}

func isValid(cur []int, wanted []int) bool {
	for i, num := range wanted {
		if cur[i] > num {
			return false
		}
	}
	return true
}

func newJoltage(cur []int, button []int) []int {
	ret := make([]int, len(cur))
	copy(ret, cur)
	for _, num := range button {
		ret[num]++
	}
	return ret
}

func merge(a, b []int) []int {
	freqs := make([]int, 1000)
	for _, num := range a {
		freqs[num]++
	}
	for _, num := range b {
		freqs[num]++
	}
	merged := make([]int, 0, len(a)+len(b))
	for num, freq := range freqs {
		if freq == 1 {
			merged = append(merged, num)
		}
	}
	return merged
}

func parse(line string) machine {
	m := machine{}
	elems := strings.Fields(line)
	pattern := strings.Trim(elems[0], "[]")

	for i, char := range pattern {
		if char == '#' {
			m.wanted = append(m.wanted, i)
		}
	}
	buttonStrings := elems[1 : len(elems)-1]
	for _, s := range buttonStrings {
		cur := make([]int, 0)
		for _, numStr := range strings.Split(strings.Trim(s, "()"), ",") {
			num, err := strconv.Atoi(numStr)
			if err != nil {
				cur = make([]int, 0)
				break
			}
			cur = append(cur, num)
		}
		if len(cur) > 0 {
			m.buttons = append(m.buttons, cur)
		}
	}
	for _, numStr := range strings.Split(strings.Trim(elems[len(elems)-1], "{}"), ",") {
		num, err := strconv.Atoi(numStr)
		if err != nil {
			break
		}
		m.joltages = append(m.joltages, num)
	}
	return m
}

func (m *machine) score(ary []int) int {
	score := 0
	for i, num := range m.joltages {
		score += (num - ary[i]) //* (rand.IntN(10) + 1)
	}
	return score
}

type heap []queueNode2

func (h *heap) insert(node queueNode2) {
	*h = append(*h, node)
	index := len(*h) - 1
	for index > 0 && ((*h)[index].score < (*h)[(index-1)/2].score) {
		(*h)[index], (*h)[(index-1)/2] = (*h)[(index-1)/2], (*h)[index]
		index = (index - 1) / 2
	}
}

func (h *heap) pop() queueNode2 {
	popped := (*h)[0]
	(*h)[0] = (*h)[len(*h)-1]
	*h = (*h)[:len(*h)-1]
	index := 0
	for index < len(*h) {
		childIndex1, childIndex2 := index*2+1, index*2+2
		if childIndex1 >= len(*h) {
			return popped
		}
		if childIndex2 >= len(*h) {
			if (*h)[childIndex1].score < (*h)[index].score {
				(*h)[childIndex1], (*h)[index] = (*h)[index], (*h)[childIndex1]
			}
			return popped
		}
		smaller := min((*h)[childIndex1].score, (*h)[childIndex2].score)
		smallerIndex := childIndex1
		if smaller == (*h)[childIndex2].score {
			smallerIndex = childIndex2
		}
		if (*h)[index].score > smaller {
			(*h)[smallerIndex], (*h)[index] = (*h)[index], (*h)[smallerIndex]
		} else {
			return popped
		}
		index = smallerIndex
	}
	return popped
}

func (m *machine) untilStopped(joltagesStart []int, button []int) ([]int, int) {
	ret := make([]int, len(joltagesStart))
	copy(ret, joltagesStart)
	maxDiff := -1
	for _, num := range button {
		diff := m.joltages[num] - joltagesStart[num]
		if diff < maxDiff || maxDiff == -1 {
			maxDiff = diff
		}
	}
	for _, i := range button {
		ret[i] += max(maxDiff, 0)
	}
	if slices.Equal(ret, m.joltages) {
		return ret, maxDiff
	}
	for !m.canIncrement(ret, button) {
		for _, num := range button {
			ret[num]--
			maxDiff--
		}
	}
	return ret, max(maxDiff, 0)
}

func (m *machine) canIncrement(cur []int, exclude []int) bool {
	for _, button := range m.buttons {
		if slices.Equal(exclude, button) {
			continue
		}
		count := 0
		for _, num := range button {
			if cur[num] >= m.joltages[num] {
				count++
			}
		}
		if count < len(button) {
			return true
		}
	}
	return false
}

func (m *machine) toMatrix() (*mat.Dense, *mat.VecDense) {
	ret := make([]float64, 0)
	joltages := make([]float64, len(m.buttons))
	for i := range m.buttons {
		if i >= len(m.joltages) {
			break
		}
		joltages[i] = float64(m.joltages[i])
	}
	for i := range m.joltages {
		row := make([]float64, len(m.buttons))
		// row[len(row)-1] = float64(joltage)
		for j, b := range m.buttons {
			if slices.Contains(b, i) {
				row[j] = 1
			}
		}
		ret = append(ret, row...)
	}
	needed := len(m.buttons) * (len(m.buttons))
	fmt.Println(needed-len(ret), "needed", ret)
	fmt.Println(ret)
	// var chol mat.Cholesky
	// m2 := mat.NewSymDense(len(m.buttons), ret)
	// ok := chol.Factorize(m2)
	// if ok {
	// 	// panic("ah")
	// 	fmt.Println(chol.Cond())
	// }

	return mat.NewDense(len(m.buttons), len(ret)/len(m.buttons), ret), mat.NewVecDense(len(m.buttons), joltages)
}
