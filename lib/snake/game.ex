defmodule Snake.Game do
  @size 10

  defstruct started: false,
            pid: nil,
            game_over: false,
            win: false,
            t: 0,
            direction: {0, 0},
            snake: [{ceil(@size / 2), ceil(@size / 2)}],
            screen_width: @size,
            screen_height: @size,
            apple: [],
            tiles: []

  # Snake game board

  use GenServer
  require Logger

  def start_game(args) do
    {:ok, pid} = start_link(args)
    {:ok, state(pid)}
  end

  def start_link(_args) do
    GenServer.start(__MODULE__, [])
  end

  def state(%__MODULE__{pid: pid}) do
    state(pid)
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def go(%__MODULE__{pid: pid}, dir) do
    go(pid, dir)
  end

  def go(pid, dir) do
    GenServer.call(pid, {:go, dir})
  end

  def update(%__MODULE__{pid: pid}) do
    update(pid)
  end

  def update(pid) do
    GenServer.call(pid, :update)
  end

  def stop_game(pid) do
    Logger.debug("stopping game #{inspect(pid)}")
    GenServer.stop(pid, :shutdown)
  end

  def init(_) do
    Logger.debug("init game")

    game =
      %__MODULE__{}
      |> gen_apple()
      |> gen_tiles()
      |> Map.put(:pid, self())

    {:ok, game}
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

    game
    |> Map.update!(:t, &(&1 + 1))
    |> move_and_eat()
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

  def move_and_eat(%{direction: {0, 0}} = game) do
    game
  end

  def move_and_eat(%{snake: snake, apple: apple} = game) do
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
    if win?(game) do
      Map.merge(game, %{game_over: true, win: true, apple: []})
    else
      Map.put(game, :apple, [next_apple_pos(w, h, snake ++ apple)])
    end
  end

  defp win?(%{snake: snake, screen_width: w, screen_height: h} = game) do
    length(snake) == w * h
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

  def gen_tiles(%{snake: snake, apple: apple, screen_width: w, screen_height: h} = game) do
    tiles =
      0..(h - 1)
      |> Enum.map(fn y ->
        0..(w - 1)
        |> Enum.map(fn x ->
          cond do
            Enum.member?(apple, {x, y}) ->
              :apple

            Enum.member?(snake, {x, y}) ->
              :snake

            true ->
              nil
          end
        end)
      end)

    game
    |> Map.put(:tiles, tiles)
  end
end
