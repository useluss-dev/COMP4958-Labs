defmodule Arithmetic.Server do
  use GenServer

  def start(n) do
    GenServer.start(__MODULE__, n, name: __MODULE__)
  end

  def square(x) do
    worker = GenServer.call(__MODULE__, :next_worker)
    Arithmetic.Worker.square(worker, x)
  end

  def sqrt(x) do
    worker = GenServer.call(__MODULE__, :next_worker)
    Arithmetic.Worker.sqrt(worker, x)
  end

  # Implementation
  @impl true
  def init(n) do
    Process.flag(:trap_exit, true)

    workers =
      Enum.map(1..n, fn _i ->
        start_worker()
      end)

    Enum.each(workers, &IO.inspect/1)

    {:ok, %{workers: workers, next_index: 0, count: n}}
  end

  @impl true
  def handle_call(:next_worker, _from, state) do
    worker = Enum.at(state.workers, state.next_index)
    next_index = rem(state.next_index + 1, state.count)
    {:reply, worker, %{state | next_index: next_index}}
  end

  @impl true
  def handle_info({:EXIT, dead_pid, _reason}, state) do
    if dead_pid in state.workers do
      new_pid = start_worker()
      IO.puts("Replacing #{inspect(dead_pid)} with #{inspect(new_pid)}")

      workers = Enum.map(state.workers, &if(&1 == dead_pid, do: new_pid, else: &1))

      {:noreply, %{state | workers: workers}}
    else
      {:noreply, state}
    end
  end

  defp start_worker() do
    {:ok, pid} = Arithmetic.Worker.start_link()
    pid
  end
end

defmodule Arithmetic.Worker do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
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
  def handle_call({:square, x}, _from, state) when is_integer(x) do
    {:reply, x * x, state}
  end

  @impl true
  def handle_call({:sqrt, x}, _from, state) when is_integer(x) do
    :timer.sleep(2000)

    {:reply, if(x < 0, do: :error, else: {:ok, :math.sqrt(x)}), state}
  end
end
