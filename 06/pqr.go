package main

import (
	"fmt"
	"sync"
)

const limit = 20

var (
	mu      sync.Mutex
	cond    *sync.Cond
	p, q, r int
)

func main() {
	cond = sync.NewCond(&mu)

	var wg sync.WaitGroup
	wg.Add(3)

	go printP(&wg)
	go printQ(&wg)
	go printR(&wg)

	wg.Wait()
}

func printP(wg *sync.WaitGroup) {
	defer wg.Done()
	for i := 0; i < limit; i++ {
		mu.Lock()
		for !(p < q) {
			cond.Wait()
		}
		fmt.Print("P")
		p++
		cond.Broadcast()
		mu.Unlock()
	}
}

func printQ(wg *sync.WaitGroup) {
	defer wg.Done()
	for i := 0; i < limit; i++ {
		mu.Lock()
		for !(q < r) {
			cond.Wait()
		}
		fmt.Print("Q")
		q++
		cond.Broadcast()
		mu.Unlock()
	}
}

func printR(wg *sync.WaitGroup) {
	defer wg.Done()
	for i := 0; i < limit; i++ {
		mu.Lock()
		fmt.Print("R")
		r++
		cond.Broadcast()
		mu.Unlock()
	}
}
