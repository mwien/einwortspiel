defmodule Einwortspiel.Generator do
  @languages %{"de" => __MODULE__.DE, "en" => __MODULE__.EN}

  def gen_nouns(k, lang) do
    Map.fetch!(@languages, lang).nouns
    |> Enum.take_random(k)
  end

  def gen_name() do
    module = Map.fetch!(@languages, "en")
    Enum.random(module.catchy_adjectives) <> Enum.random(module.catchy_nouns)
  end

  def gen_id() do 
    :crypto.strong_rand_bytes(10) |> Base.url_encode64()
  end
end
