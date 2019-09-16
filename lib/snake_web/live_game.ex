defmodule SnakeWeb.LiveGame do
  @moduledoc """
  This module is the LiveView server for the game.
  """

  use Phoenix.LiveView

  def render(%{game: nil} = assigns) do
    ~L"""
    <button phx-click="start">start</button>
    """
  end

  def render(%{game: %Snake.Game{}} = assigns) do
    ~L"""
    <header>
      <%= @game.snake |> length %>
      <%= if @game.game_over, do: "Game Over, You #{if @game.win, do: "Win!", else: "Lose!"}" %>
    </header>

    <% w = "#{floor(100 / @game.screen_width)}%" %>

    <ul phx-keyup="turn" phx-target="window">
      <%= for x <- 1..@game.screen_width, y <- 1..@game.screen_height do %>
        <% tile = @game.tiles |> Enum.at(x - 1) |> Enum.at(y - 1) %>

        <%= if tile == :apple do %>
          <li class="apple" style="width: <%= w %>"></li>
        <% end %>

        <%= if tile == :snake do %>
          <li class="snake" style="width: <%= w %>"></li>
        <% end %>

        <%= if is_nil(tile) do %>
          <li style="width: <%= w %>"></li>
        <% end %>

      <% end %>
    </ul>
    """
  end

  def mount(_, socket) do
    {:ok, socket |> assign(:game, nil)}
  end

  def terminate(reason, socket) do
    game = socket.assigns[:game]

    if game do
      Snake.Game.stop_game(game)
    end
  end

  def handle_info(:update, socket) do
    game =
      socket.assigns[:game]
      |> Snake.Game.update()

    unless game.game_over do
      :timer.send_after(1000, self(), :update)
    end

    {:noreply, socket |> assign(:game, game)}
  end

  def handle_event("start", _, socket) do
    {:ok, game} = Snake.Game.start_game([])

    socket =
      socket
      |> assign(:game, game)

    handle_info(:update, socket)

    {:noreply, socket}
  end

  @left_key 37
  @up_key 38
  @right_key 39
  @down_key 40

  @keys [@left_key, @up_key, @right_key, @down_key]

  def handle_event("turn", %{"keyCode" => key}, socket) when key in @keys do
    direction = dir(key)

    game =
      socket.assigns[:game]
      |> Snake.Game.turn(direction)

    {:noreply, socket |> assign(:game, game)}
  end

  def handle_event("turn", key, socket) do
    {:noreply, socket}
  end

  defp dir(@left_key), do: {-1, 0}
  defp dir(@right_key), do: {1, 0}
  defp dir(@up_key), do: {0, -1}
  defp dir(@down_key), do: {0, 1}
end
