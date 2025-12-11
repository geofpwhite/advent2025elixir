package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	f, err := os.Open("inputs/advent11.txt")
	// f, err := os.Open("inputs/advent11test2.txt")
	if err != nil {
		panic("can't open")
	}
	defer f.Close()
	scanner := bufio.NewScanner(f)
	g := make(graph)
	for scanner.Scan() {
		name, node := parseLine(scanner.Text())
		g[name] = node
	}
	for k, n := range g {
		for _, s := range n.children {
			if g[s] == nil {
				g[s] = new(node)
			}
			g[s].parents = append(g[s].parents, k)
		}
	}
	f.Close()

	// x := g.traverse("svr")
	toOut := g.traverse("dac", "out")
	// x := g.traverse("dac", "fft")
	// x := g.traverseBackwards("dac", "fft")

	// x := g.traverse("taz", "out")
	// x := g.traverse("rof", "out")
	toFft := g.traverse("svr", "fft")
	toDac := g.traverse("fft", "dac")
	fmt.Println(toOut * toFft * toDac)
	// fmt.Println(g.allChildren("fft", make(map[string]bool)))
}

type graph map[string]*node

type node struct {
	children []string
	parents  []string
}

func (g *graph) allChildren(node string, curChildren map[string]bool) map[string]bool {
	curChildren[node] = true
	for _, child := range (*g)[node].children {
		if !curChildren[child] {
			curChildren = g.allChildren(child, curChildren)
		}
	}
	return curChildren
}

func (g *graph) allParents(node string, curChildren map[string]bool) map[string]bool {
	curChildren[node] = true
	if (*g)[node] == nil {
		return curChildren
	}
	for _, child := range (*g)[node].parents {
		if !curChildren[child] {
			curChildren = g.allParents(child, curChildren)
		}
	}
	return curChildren
}

func parseLine(line string) (string, *node) {
	strs := strings.Split(line, " ")
	return strings.Replace(strs[0], ":", "", -1), &node{children: strs[1:]}
}

type queueNode11 struct {
	node string
	path []string
}

func (g *graph) traverseBackwards(start, end string) int {
	count := 0
	queue := []queueNode11{
		{node: start, path: make([]string, 0)},
	}
	var cur queueNode11
	for len(queue) > 0 {
		cur, queue = queue[0], queue[1:]
		// fmt.Println(cur.node, count)

		if cur.node == end {

			// if validPath(cur.path) {
			count++
			// }
			continue
		}
		if cur.node == "svr" {
			continue
		}
		n := (*g)[cur.node]
		for _, neighbor := range n.parents {
			// fmt.Println(cur.node, "to", neighbor)
			queue = append(queue, queueNode11{node: neighbor, path: append(cur.path, neighbor)})
		}
	}
	return count
}

func (g *graph) traverse(start, end string) int {
	parents := g.allParents(end, make(map[string]bool))
	fmt.Println(parents)
	count := 0
	queue := []queueNode11{
		{node: start, path: make([]string, 0)},
	}
	var cur queueNode11
	for len(queue) > 0 {
		cur, queue = queue[0], queue[1:]
		// fmt.Println(cur.node, count, len(cur.path))

		if cur.node == end {

			// if validPath(cur.path) {
			count++
			// }
			continue
		}
		if cur.node == "out" {
			continue
		}
		n := (*g)[cur.node]
		if n == nil {
			n = new(node)
		}
		for _, neighbor := range n.children {
			// fmt.Println(cur.node, "to", neighbor)
			if parents[neighbor] {
				queue = append(queue, queueNode11{node: neighbor, path: append(cur.path, neighbor)})
			}
		}
	}
	return count
}

func validPath(path []string) bool {
	dac, fft := false, false
	for _, str := range path {
		switch str {
		case "dac":
			dac = true
		case "fft":
			fft = true
		}
		if dac && fft {
			return true
		}
	}
	return dac && fft
}
