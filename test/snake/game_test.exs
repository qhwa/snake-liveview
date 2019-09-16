defmodule Snake.GameTest do
  use ExUnit.Case, async: true

  alias Snake.Game

  test "it works" do
    assert {:ok, %Game{}} = Game.start_game([])
  end

  test "snake can turn left/right" do
    {:ok, game} = Game.start_game([])
    game = Game.turn(game, {-1, 0})

    assert game.direction == {-1, 0}
  end
end
