defmodule Primes do
  # Part 1
  def primes(n) do
    sieve(Enum.to_list(2..n), [], n)
  end

  defp sieve([], primes, _n) do
    Enum.reverse(primes)
  end

  defp sieve([p | t] = nums, primes, n) do
    if p * p > n do
      sieve([], primes, n) ++ nums
    else
      sieve(Enum.filter(t, fn x -> x < p * p or rem(x, p) != 0 end), [p | primes], n)
    end
  end

  # Part 2
  def largest_perm_set(lst) do
    Enum.group_by(lst, fn x ->
      Integer.to_string(x)
      |> String.graphemes()
      |> Enum.sort()
    end)
    |> Map.values()
    |> Enum.map(&length/1)
    |> Enum.max()
  end
end

lst =
  Primes.primes(1_000_000)
  |> Enum.filter(fn x -> x > 99_999 end)

perm_set = Primes.largest_perm_set(lst)

IO.puts("#{length(lst)}, 6 digit primes.")

IO.puts(
  "Largest set of 6 digit primes that are permutations of each other is #{perm_set} primes."
)
