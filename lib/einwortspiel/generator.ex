defmodule Einwortspiel.Generator do
  @languages %{"de" => __MODULE__.DE, "en" => __MODULE__.EN}

  def gen_words(k, lang) do
    Map.fetch!(@languages, lang).words
    |> Enum.take_random(k)
  end

  def gen_name() do
    module = Map.fetch!(@languages, "en")
    Enum.random(module.catchy_adjectives) <> Enum.random(module.catchy_nouns)
  end
end
