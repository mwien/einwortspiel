defmodule Einwortspiel.Game.Chat do
  def init(), do: []
  def add_message(chat, player_id, message), do: [{player_id, message} | chat]
end
