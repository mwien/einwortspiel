defmodule Einwortspiel.Generator do

  # this is not best solution -> recompile force necessary
  # also duplicate code
  @nouns_de File.read!("lib/einwortspiel/generator/nouns_de.txt")
         |> String.split() |> Enum.map(&String.trim(&1))

  @nouns_en File.read!("lib/einwortspiel/generator/nouns_en.txt")
         |> String.split() |> Enum.map(&String.trim(&1))

  @catchy_adjectives File.read!("lib/einwortspiel/generator/catchy_adjectives_en.txt")
         |> String.split() |> Enum.map(&String.trim(&1))

  @catchy_nouns File.read!("lib/einwortspiel/generator/catchy_nouns_en.txt")
         |> String.split() |> Enum.map(&String.trim(&1))

  @languages %{"de" => @nouns_de, "en" => @nouns_en}

  def gen_words(k, lang) do
    Map.get(@languages, lang)
    |> Enum.take_random(k)
  end

  def gen_name() do
    Enum.random(@catchy_adjectives) <> Enum.random(@catchy_nouns)
  end
end
