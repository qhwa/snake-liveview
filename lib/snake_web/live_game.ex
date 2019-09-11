defmodule SnakeWeb.LiveGame do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <header>
      <%= @game.snake |> length %>
      <%= if @game.game_over, do: "Game Over" %>
    </header>
    <ul phx-keyup="turn" phx-target="window">
      <%= for x <- 1..@game.screen_width, y <- 1..@game.screen_height do %>
        <% tile = @game.tiles |> Enum.at(x - 1) |> Enum.at(y - 1) %>

        <%= if tile == :apple do %>
          <li class="apple"></li>
        <% end %>

        <%= if tile == :snake do %>
          <li class="snake"></li>
        <% end %>

        <%= if is_nil(tile) do %>
          <li></li>
        <% end %>

      <% end %>
    </ul>
    """
  end

  def mount(_, socket) do
    if connected?(socket) do
      :timer.send_after(1000, self(), :update)
    end

    {:ok, pid} = Snake.Game.start_link([])
    game = Snake.Game.state(pid)
    {:ok, socket |> assign(:game_pid, pid) |> assign(:game, game)}
  end

  def terminate(reason, socket) do
    Snake.Game.stop_game(socket.assigns.game_pid)
  end

  def handle_info(:update, socket) do
    pid = socket.assigns.game_pid
    game = Snake.Game.update(pid)

    unless game.game_over do
      :timer.send_after(1000, self(), :update)
    end

    {:noreply, socket |> assign(:game, game)}
  end

  @left_key 37
  @up_key 38
  @right_key 39
  @down_key 40

  @arrows [@left_key, @up_key, @right_key, @down_key]

  def handle_event("turn", %{"keyCode" => key}, socket) when key in @arrows do
    pid = socket.assigns.game_pid
    game = Snake.Game.go(pid, dir(key))
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
