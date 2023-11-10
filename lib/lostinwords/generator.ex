defmodule Lostinwords.Generator do

  # this is not best solution -> recompile force necessary
  @nouns File.read!("lib/lostinwords/generator/nouns_de.txt")
         |> String.split()
  @catchy_adjectives File.read!("lib/lostinwords/generator/catchy_adjectives_en.txt")
         |> String.split()

  @catchy_nouns File.read!("lib/lostinwords/generator/catchy_nouns_en.txt")
         |> String.split()

  def gen_words(k) do
    Enum.take_random(@nouns, k)
  end

  def gen_name() do
    Enum.random(@catchy_adjectives) <> Enum.random(@catchy_nouns)
  end
end
