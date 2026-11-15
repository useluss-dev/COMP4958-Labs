defmodule Card.Worker do
  use GenServer
  @registry Card.Registry
  @table Card.Table

  # Client API
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via(name))
  end

  def new(name) do
    GenServer.cast(via(name), :new)
  end

  def shuffle(name) do
    GenServer.cast(via(name), :shuffle)
  end

  def count(name) do
    GenServer.call(via(name), :count)
  end

  def deal(name, n \\ 1) do
    GenServer.call(via(name), {:deal, n})
  end

  # Implmentation
  @impl true
  def init(arg) do
    name = {__MODULE__, arg}

    value =
      case :ets.lookup(@table, name) do
        [] -> new_deck()
        [{_, v}] -> v
      end

    IO.puts("Card worker #{arg} started with pid #{inspect(self())}")
    {:ok, {name, value}}
  end

  @impl true
  def handle_call(:count, _from, {_, deck} = state) do
    {:reply, length(deck), state}
  end

  @impl true
  def handle_call({:deal, n}, _from, {name, deck}) when is_integer(n) do
    cond do
      n < 0 ->
        {:reply, {:error, "Cannot deal negative cards!"}, {name, deck}}

      n > length(deck) ->
        {:reply, {:error, "Insufficent cards remaining"}, {name, deck}}

      true ->
        {:reply, {:ok, Enum.take(deck, n)}, {name, Enum.drop(deck, n)}}
    end
  end

  @impl true
  def handle_cast(:shuffle, {name, deck}) do
    {:noreply, {name, Enum.shuffle(deck)}}
  end

  @impl true
  def handle_cast(:new, {name, _deck}) do
    {:noreply, {name, new_deck()}}
  end

  @impl true
  def terminate(_reason, deck), do: :ets.insert(@table, deck)

  # Helpers
  defp new_deck() do
    values = Enum.map(2..10, &Integer.to_string(&1)) ++ ["J", "Q", "K", "A"]

    suits = ["\u2663", "\u2666", "\u2665", "\u2660"]
    for v <- values, s <- suits, do: v <> s
  end

  defp via(name) do
    {:via, Registry, {@registry, {__MODULE__, name}}}
  end
end
