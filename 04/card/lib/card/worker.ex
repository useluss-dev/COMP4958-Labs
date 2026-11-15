defmodule Card.Worker do
  use GenServer

  @store Card.Store

  # Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def new() do
    GenServer.cast(__MODULE__, :new)
  end

  def shuffle() do
    GenServer.cast(__MODULE__, :shuffle)
  end

  def count() do
    GenServer.call(__MODULE__, :count)
  end

  def deal(n \\ 1) do
    GenServer.call(__MODULE__, {:deal, n})
  end

  # Implmentation
  @impl true
  def init(_arg) do
    Process.flag(:trap_exit, true)

    case @store.get() do
      nil ->
        IO.puts("Card.Worker started with new deck")
        {:ok, new_deck()}

      deck ->
        IO.puts("Card.Worker started with deck restored from store")
        {:ok, deck}
    end
  end

  @impl true
  def handle_call(:count, _from, deck) do
    {:reply, length(deck), deck}
  end

  @impl true
  def handle_call({:deal, n}, _from, deck) when is_integer(n) do
    cond do
      n < 0 ->
        {:reply, {:error, "Cannot deal negative cards!"}, deck}

      n > length(deck) ->
        {:reply, {:error, "Insufficent cards remaining"}, deck}

      true ->
        {:reply, {:ok, Enum.take(deck, n)}, Enum.drop(deck, n)}
    end
  end

  @impl true
  def handle_cast(:shuffle, deck) do
    {:noreply, Enum.shuffle(deck)}
  end

  @impl true
  def handle_cast(:new, _deck) do
    {:noreply, new_deck()}
  end

  @impl true
  def terminate(_reason, deck), do: @store.put(deck)

  defp new_deck() do
    values = Enum.map(2..10, &Integer.to_string(&1)) ++ ["J", "Q", "K", "A"]

    suits = ["\u2663", "\u2666", "\u2665", "\u2660"]
    for v <- values, s <- suits, do: v <> s
  end
end
