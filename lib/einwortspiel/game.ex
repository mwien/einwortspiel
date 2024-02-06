defmodule Einwortspiel.Game do
  alias __MODULE__

  defstruct [
    :id,
    :players
  ]

  def init_game(_options) do
    %Game{
      id: generate_game_id(),
      players: %{}
    }
  end

  def has_player?(game, player_id) do
    Map.has_key?(game.players, player_id)
  end

  def add_player(game, player_id, name) do
    # replace by Player.create_player(name)
    new_player = name
    {[{:add_player, player_id, new_player}] ,%Game{game | players: Map.put(game.players, player_id, new_player)}}
  end

  # have general generate id function -> in generator!!!!!!
  defp generate_game_id() do
    :crypto.strong_rand_bytes(10) |> Base.url_encode64()
  end
end
