defmodule Einwortspiel.Game.Settings do
  alias __MODULE__

  defstruct language: "de",
            nr_commonwords: 2

  def init(options) do
    struct(%Settings{}, options)
  end
end
