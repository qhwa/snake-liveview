defmodule SnakeWeb.PageController do
  use SnakeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
