defmodule Einwortspiel.Words do
  @languages %{"de" => __MODULE__.DE, "en" => __MODULE__.EN}
  
  def gen_words(k, lang) do
    Map.fetch!(@languages, lang).words
    |> Enum.take_random(k)
  end 
end
