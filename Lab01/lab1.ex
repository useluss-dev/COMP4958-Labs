defmodule Lab1 do
  # Part 1
  defp inverse_mod(newr, _newt, r, t) when newr == 0, do: {r, t}

  defp inverse_mod(newr, newt, r, t) do
    quotient = div(r, newr)

    inverse_mod(
      r - quotient * newr,
      t - quotient * newt,
      newr,
      newt
    )
  end

  def inverse_mod(a, n) do
    {r, t} = inverse_mod(a, 1, n, 0)

    cond do
      r > 1 -> :not_invertible
      t < 0 -> t + n
      true -> t
    end
  end

  # Part 2
  defp pow_mod(_a, m, n, acc) when m == 0, do: rem(acc, n)

  defp pow_mod(a, m, n, acc) when m > 0 do
    if rem(m, 2) != 0 do
      pow_mod(rem(a * a, n), div(m, 2), n, rem(acc * a, n))
    else
      pow_mod(rem(a * a, n), div(m, 2), n, acc)
    end
  end

  def pow_mod(a, m, n) do
    pow_mod(rem(a, n), m, n, 1)
  end
end
