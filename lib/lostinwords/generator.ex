defmodule Lostinwords.Generator do
  @nouns File.read!("lib/lostinwords/generator/nouns_de.txt")
        |> String.split()
  @catchy_adjectives File.read!("lib/lostinwords/generator/catchy_adjectives_en.txt")
        |> String.split()

  @catchy_nouns File.read!("lib/lostinwords/generator/catchy_nouns_en.txt")
        |> String.split()

  @animals File.read!("lib/lostinwords/generator/animals_en.txt")
        |> String.split("\n", trim: true)

  def gen_words(k) do
    Enum.take_random(@nouns, k)
  end

  def gen_name() do
    Enum.random(@catchy_adjectives) <> Enum.random(@catchy_nouns)
  end

  def gen_animal() do
    IO.inspect(@animals)
    [animal, svgfile] = Enum.random(@animals)
          |> IO.inspect()
          |> String.split()
    {Enum.random(@catchy_adjectives) <> animal, svgfile}
  end

end
