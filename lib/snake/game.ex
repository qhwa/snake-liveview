defmodule Snake.Game do

  defstruct started: false, game_over: false, snake_shape: [{0, 0}], t: 0

  # Snake game board

  use GenServer

  def start_link(_args) do
    GenServer.start(__MODULE__, [])
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def update(pid) do
    GenServer.call(pid, :update)
  end

  def init(_) do
    {:ok, %__MODULE__{}}
  end

  def handle_call(:state, _from, game) do
    {:reply, game, game}
  end

  def handle_call(:update, _from, game) do
    game =
      game
      |> Map.update!(:t, &(&1 + 1))
      |> Map.put(:started, true)

    {:reply, game, game}
  end

end
