package main

import (
	"fmt"
	"maps"
	"slices"
	"sort"
	"strconv"
)

func sieve(n int) []int {
	is_prime := make([]bool, n+1)
	for i := range is_prime {
		is_prime[i] = true
	}
	is_prime[0] = false
	is_prime[1] = false

	p := 2

	for p <= n/p {
		if is_prime[p] {
			multiple := p * p

			for multiple <= n {
				is_prime[multiple] = false
				multiple += p
			}

		}
		p++
	}

	var primes []int
	for i, val := range is_prime {
		if val {
			primes = append(primes, i)
		}
	}

	return primes
}

func primes(m, n int) []int {
	if m > n || n < 2 {
		return []int{}
	}

	primes := sieve(n)
	var primes_filtered []int
	for _, p := range primes {
		if p >= m {
			primes_filtered = append(primes_filtered, p)
		}
	}
	return primes_filtered
}

func sort_num(n int) string {
	digits := []rune(strconv.Itoa(n))
	slices.Sort(digits)
	return string(digits)
}

func main() {
	primes := primes(100_000, 1_000_000)

	var sorted_primes []string
	for _, p := range primes {
		sorted_primes = append(sorted_primes, sort_num(p))
	}

	counts := make(map[string]int)
	for _, p := range sorted_primes {
		counts[p] += 1
	}
	count_vals := slices.Collect(maps.Values(counts))
	sort.Sort(sort.Reverse(sort.IntSlice(count_vals)))

	fmt.Printf("%d, 6 digit primes\n", len(primes))
	fmt.Printf("Largest set of 6 digit primes that are permutations of each other is %d primes.\n", count_vals[0])
}
