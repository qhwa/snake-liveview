defmodule Snake.Game do

  defstruct started: false,
    game_over: false,
    t: 0,
    direction: {0, 0},
    snake_tiles: [{5, 5}, {6, 5}, {7, 5}, {7, 6}],
    screen_width: 10,
    screen_height: 10

  # Snake game board

  use GenServer
  require Logger

  def start_link(_args) do
    GenServer.start(__MODULE__, [])
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def go(pid, dir) do
    GenServer.call(pid, {:go, dir})
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
      |> tick()

    {:reply, game, game}
  end

  def handle_call({:go, {dx, dy}}, _from, game) do
    game =
      game
      |> Map.put(:direction, {dx, dy})
      |> start()

    {:reply, game, game}
  end

  def start(%{started: true} = game), do: game

  def start(game) do
    Logger.info("Game started")

    game
    |> Map.put(:started, true)
    |> tick()
  end

  def tick(game) do
    Logger.debug("tick, #{game.t}")
    # Process.send_after(self(), :tick, 1000)

    game
    |> Map.update!(:t, &(&1 + 1))
    |> move()
  end

  def move(%{direction: {0, 0}} = game) do
    game
  end

  def move(game) do
    {dx, dy} = game.direction
    [{x, y} | tail] = game.snake_tiles

    tiles = [{
      within(x + dx, game.screen_width),
      within(y + dy, game.screen_height)
    }] ++ [{x, y}] ++ (tail |> Enum.drop(-1))

    game
    |> Map.put(:snake_tiles, tiles)
    |> Map.put(:started, true)
  end

  defp within(pos, max) do
    cond do
      pos < 0 -> pos + max
      pos >= max -> pos - max
      true -> pos
    end
  end

end
