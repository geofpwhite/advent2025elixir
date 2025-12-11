package main

import (
	"bufio"
	"fmt"
	"maps"
	"os"
	"slices"
	"strconv"
	"strings"
)

type coords struct {
	x, y, z int
}

func parse() []coords {
	f, err := os.Open("inputs/advent8.txt")
	if err != nil {
		panic("file not found")
	}
	defer f.Close()
	scanner := bufio.NewScanner(f)
	boxes := make([]coords, 0, 1000)
	for scanner.Scan() {
		numStrings := strings.Split(scanner.Text(), ",")
		if len(numStrings) != 3 {
			continue
		}
		x, _ := strconv.Atoi(numStrings[0])
		y, _ := strconv.Atoi(numStrings[1])
		z, _ := strconv.Atoi(numStrings[2])
		boxes = append(boxes, coords{x, y, z})
	}
	if scanner.Err() != nil {
		panic("could ")
	}
	return boxes
}

func (c coords) distance(other coords) int {
	return ((c.x - other.x) * (c.x - other.x)) + ((c.y - other.y) * (c.y - other.y)) + ((c.z - other.z) * (c.z - other.z))
}

func main() {
	boxes := parse()
	pairs := pairDistances(boxes)
	circuits := make([]map[coords]bool, len(boxes))
	for i := range circuits {
		circuits[i] = map[coords]bool{
			boxes[i]: true,
		}
	}
	for _, pairwise := range pairs[:1000] {
		toRemove := join(pairwise, circuits)
		if toRemove == -1 {
			continue
		}
		circuits = append(circuits[:toRemove], circuits[toRemove+1:]...)
	}
	slices.SortFunc(circuits, func(a, b map[coords]bool) int {
		return len(b) - len(a)
	})
	fmt.Println(len(circuits[0]) * len(circuits[1]) * len(circuits[2]))
	for _, pairwise := range pairs[1000:] {
		toRemove := join(pairwise, circuits)
		if len(circuits) == 2 && toRemove != -1 {
			fmt.Println(pairwise.a.x * pairwise.b.x)
			return
		}
		if toRemove == -1 {
			continue
		}
		circuits = append(circuits[:toRemove], circuits[toRemove+1:]...)
	}
}

func join(pair pairWise, circuits []map[coords]bool) int {
	aIndex, bIndex := -1, -1
	for i, circuit := range circuits {
		if circuit[pair.a] {
			aIndex = i
		}
		if circuit[pair.b] {
			bIndex = i
		}
		if aIndex != -1 && bIndex != -1 {
			break
		}
	}
	maps.Copy(circuits[aIndex], circuits[bIndex])
	if bIndex == aIndex {
		return -1
	}
	return bIndex
}

type pairWise struct {
	a, b     coords
	distance int
}

func pairDistances(boxes []coords) []pairWise {
	length := len(boxes)
	pairs := make([]pairWise, 0, (length*(length-1))/2)
	for i, coord1 := range boxes {
		for _, coord2 := range boxes[i+1:] {
			pairs = append(pairs, pairWise{coord1, coord2, coord1.distance(coord2)})
		}
	}
	slices.SortFunc(pairs, func(a, b pairWise) int {
		return a.distance - b.distance
	})
	return pairs
}
