defmodule SnakeWeb.LiveGame do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    Hello world! <%= @game.t %>
    <button phx-click="start">start<button>
    """
  end

  def mount(_, socket) do
    {:ok, pid} = Snake.Game.start_link([])
    game = Snake.Game.state(pid)
    {:ok, socket |> assign(:game_pid, pid) |> assign(:game, game)}
  end

  def handle_info(:update, socket) do
    pid = socket.assigns.game_pid
    game = Snake.Game.update(pid)

    {:noreply, socket |> assign(:game, game)}
  end

  def handle_event("start", _params, socket) do
    :timer.send_interval(1000, self(), :update)
    {:noreply, socket}
  end
end
