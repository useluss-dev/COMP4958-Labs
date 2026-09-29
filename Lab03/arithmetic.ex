defmodule Arithmetic.Server do
  use GenServer

  def start(n) do
    GenServer.start(__MODULE__, n, name: __MODULE__)
  end

  def square(x) do
    GenServer.call(__MODULE__, {:square, x})
  end

  def sqrt(x) do
    GenServer.call(__MODULE__, {:sqrt, x})
  end

  # Implementation
  @impl true
  def init(n) do
    workers =
      Enum.map(1..n, fn _i ->
        {:ok, pid} = Arithmetic.Worker.start()
        pid
      end)

    print_workers(workers)

    {:ok, %{workers: workers, next_index: 0, count: n}}
  end

  @impl true
  def handle_call({operation, x}, from, state)
      when operation in [:square, :sqrt] do
    {worker, next_index} = get_next_worker(state)

    # Do not block the GenServer callback.
    spawn(fn ->
      result =
        case operation do
          :square -> Arithmetic.Worker.square(worker, x)
          :sqrt -> Arithmetic.Worker.sqrt(worker, x)
        end

      # Reply to the process that called GenServer.call/2.
      GenServer.reply(from, result)
    end)

    {:noreply, %{state | next_index: next_index}}
  end

  # Helpers
  defp print_workers(workers) do
    Enum.each(workers, fn pid ->
      IO.puts("#{inspect(pid)}")
    end)
  end

  defp get_next_worker(state) do
    worker = Enum.at(state.workers, state.next_index)
    next_index = rem(state.next_index + 1, state.count)
    {worker, next_index}
  end
end

defmodule Arithmetic.Worker do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  def square(pid, x) do
    {pid, GenServer.call(pid, {:square, x})}
  end

  def sqrt(pid, x) do
    {pid, GenServer.call(pid, {:sqrt, x})}
  end

  # Implementation
  @impl true
  def init(_arg) do
    {:ok, nil}
  end

  @impl true
  def handle_call({:square, x}, _from, state) do
    {:reply, x * x, state}
  end

  @impl true
  def handle_call({:sqrt, x}, _from, state) do
    :timer.sleep(2000)

    {:reply, if(x < 0, do: :error, else: {:ok, :math.sqrt(x)}), state}
  end
end
