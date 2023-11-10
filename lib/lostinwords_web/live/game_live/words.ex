defmodule LostinwordsWeb.GameLive.Words do
  use Phoenix.Component

  attr :words, :list
  attr :active, :boolean
  attr :correctword, :string 
  attr :guess, :string 
  attr :show, :boolean
  # attr :guessed_by, :map 
  # attr :highlighted, :map
  # do grid -> for mobile one col -> else two or three
  def render(assigns) do
    ~H"""
      <div class="flex justify-evenly"> 
        <.word
          :for={word <- @words}
          value = {word}
          classstr = {highlight(word == @guess, word == @correctword, @show)}
          {getextra(%{}, @active)
          }
        />
      </div>
    """
  end

  attr :value, :string
  attr :classstr, :string
  attr :rest, :global
  # TODO: maybe rename card?
  def word(assigns) do
    ~H""" 
    <button
      phx-click="submit_guess"
      value={@value}
      class={"rounded-lg h-24 w-48
      shadow-md flex flex-col justify-center items-center" <> @classstr }
      {@rest}
    >
      <%= @value %>
    </button>
    """
  end

  # do nicer!
  def getextra(rest, flag) do
    if flag do
      rest
    else
      Map.put(rest, :disabled, "true")
    end
  end

  def highlight(chosen, correct, show) do
    if show do
      put_chosen("", chosen)
      |> put_correct(correct, chosen)
    else 
      "" 
    end

  end

  def put_chosen(str, chosen) do
    case chosen do
      true -> str <> " border-8"
        _ -> str
    end
  end
  
  def put_correct(str, correct, chosen) do
    cond do
      correct -> str <> " bg-green-300 "
      chosen and not correct -> str <> " bg-red-400 "
      true -> " bg-white"
    end
  end
end
