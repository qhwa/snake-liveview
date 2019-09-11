defmodule Snake.Game do

  defstruct started: false,
    game_over: false,
    t: 0,
    direction: {0, 0},
    snake: [{5, 5}],
    screen_width: 10,
    screen_height: 10,
    apple: [],
    tiles: []

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

  def stop_game(pid) do
    Logger.debug("stopping game #{inspect pid}")
    GenServer.stop(pid, :shutdown)
  end

  def init(_) do
    {:ok, %__MODULE__{} |> gen_apple() |> gen_tiles()}
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
    |> eat()
    |> gen_tiles()
  end

  def move(%{direction: {0, 0}} = game) do
    game
  end

  def move(game) do
    next = next_pos(game)

    cond do
      Enum.member?(game.snake, next) ->
        game
        |> Map.put(:game_over, true)

      true ->
        game
        |> Map.put(:snake, [next] ++ (game.snake |> Enum.drop(-1)))
        |> Map.put(:started, true)
    end
  end

  defp next_pos(game) do
    [{x, y} | _] = game.snake
    {dx, dy} = game.direction

    {
      within(x + dx, game.screen_width),
      within(y + dy, game.screen_height)
    }
  end

  defp within(pos, max) do
    cond do
      pos < 0 -> pos + max
      pos >= max -> pos - max
      true -> pos
    end
  end

  def eat(%{snake: snake, apple: apple} = game) do
    next = next_pos(game)

    if Enum.member?(apple, next) do
      snake = [next] ++ snake

      game
      |> Map.put(:snake, snake)
      |> gen_apple()
    else
      game
      |> move()
    end
  end

  defp gen_apple(%{snake: snake, apple: apple, screen_width: w, screen_height: h} = game) do
    game
    |> Map.put(:apple, [next_apple_pos(w, h, snake ++ apple)])
  end

  defp next_apple_pos(w, h, taken) do
    pos = {
      Enum.random(0..(w - 1)),
      Enum.random(0..(h - 1))
    }

    if Enum.member?(taken, pos) do
      next_apple_pos(w, h, taken)
    else
      pos
    end
  end


  defp gen_tiles(%{snake: snake, apple: apple, screen_width: w, screen_height: h} = game) do
    tiles =
      (0..(h - 1))
      |> Enum.map(fn y ->
        (0..(w - 1))
        |> Enum.map(fn x ->
          cond do
            Enum.member?(apple, {x, y}) ->
              :apple
            Enum.member?(snake, {x, y}) ->
              :snake
            true ->
              :nil
          end
        end)
      end)

    game
    |> Map.put(:tiles, tiles)
  end

end
