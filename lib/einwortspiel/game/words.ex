defmodule Einwortspiel.Game.Words do
  alias __MODULE__ 
  alias Einwortspiel.Generator

  defstruct [
    :commonwords, # typespecs
    :extrawords,
    :shuffle
  ]

  def generate(players, settings) do
    {commonwords, extrawords} = Generator.gen_nouns(length(players) + settings.nr_commonwords, settings.language)
    |> Enum.split(settings.nr_commonwords)
    
    %Words{
      commonwords: commonwords,
      extrawords: Map.new(Enum.zip(players, extrawords)),
      shuffle: Map.new(Enum.map(players, &{&1, Enum.shuffle([0,1,2])}))
    }
  end

  def get_extraword(words, player) do
    Map.get(words.extrawords, player)
  end
  
  def get_words(words, player) do
    [get_extraword(words, player) | words.commonwords]
    |> Enum.zip(words.shuffle[player])
    |> Enum.sort_by(&elem(&1, 1))
    |> Enum.unzip()
    |> elem(0)
  end
end
