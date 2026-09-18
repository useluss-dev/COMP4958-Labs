defmodule CardServer do
  def start() do
    spawn(fn -> loop(new()) end)
  end

  defp new() do
    values =
      Enum.to_list(2..10, fn x -> Integer.to_string(x) end) ++ ["J", "Q", "K", "A"]

    suits = ["\u2663", "\u2666", "\u2665", "\u2660"]
    for v <- values, s <- suits, do: v <> s
  end

  def new(pid) do
    send(pid, :new)
  end

  def shuffle(pid) do
    send(pid, :shuffle)
  end

  def count(pid) do
    send(pid, {self(), :count})

    receive do
      x -> x
    end
  end

  def deal(pid, n \\ 1) do
    send(pid, {self(), :deal, n})

    receive do
      {:error, msg} -> msg
      {:ok, dealt} -> dealt
    end
  end

  defp loop(deck) do
    receive do
      :new ->
        loop(new())

      :shuffle ->
        loop(Enum.shuffle(deck))

      {from, :count} ->
        send(from, length(deck))
        loop(deck)

      {from, :deal, n} ->
        cond do
          n < 0 ->
            send(from, {:error, "Cannot deal negative cards!"})
            loop(deck)

          n > length(deck) ->
            send(from, {:error, "Insufficient cards remaining."})
            loop(deck)

          true ->
            send(from, {:ok, Enum.take(deck, n)})
            loop(Enum.drop(deck, n))
        end
    end
  end
end
