defmodule LostinwordsWeb.GameLive.Words do
  use Phoenix.Component

  attr :words, :list
  attr :active, :boolean
  # attr :guessed_by, :map 
  # attr :highlighted, :map
  # do grid -> for mobile one col -> else two or three
  def render(assigns) do
    ~H"""
      <div class="flex flex-col items-center"> 
        <.word
          :for={word <- @words}
          value = {word}
          {getextra(%{}, @active)}
        />
      </div>
    """
  end

  attr :value, :string
  attr :rest, :global
  # TODO: maybe rename card?
  def word(assigns) do
    ~H""" 
    <button
      phx-click="submit_guess"
      value={@value}
      class={"rounded-lg h-16 w-48 border-gray-200
      shadow-md text-xl flex flex-col justify-center font-oswald "}
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


  attr :id, :string, required: true
  attr :items, :list, required: true
  # maybe change this later
  attr :guessed_by, :map, required: true
  attr :clickable, :boolean, default: true
  # this might make lostwords handling easier
  attr :highlighted, :list, default: []

  def cards(assigns) do
    ~H"""
    <div id={@id} class="grid grid-cols-2 gap-4 justify-items-center m-2">
      <.card
        :for={item <- @items}
        id={"#{@id}-#{Phoenix.Param.to_param(item)}"}
        item={item}
        guessers={Map.get(@guessed_by, item)}
        {
          %{}
          |> getextra(@clickable)
          |> ishighlighted(item, @highlighted)
        }
      />
    </div>
    """
  end


  def ishighlighted(rest, item, highlighted) do
    if Enum.member?(highlighted, item) do
      Map.put(rest, :class, "bg-green-400")
    else
      Map.put(rest, :class, "bg-slate-100")
    end
  end

  # TODO: so many ugly stuff here :/

  attr :id, :string, required: true
  # TODO: what if not string
  attr :item, :string, required: true
  attr :guessers, :list, required: true
  # , include: ~w(disabled) 
  attr :rest, :global, default: %{class: ""}
  # TODO: render guesser list by having some list thingy
  # TODO: maybe add attribute just for extra class attr
  def card(assigns) do
    ~H"""
    <button
      phx-click="submit_guess"
      value={@item}
      class={"rounded-lg h-16 w-36 border-gray-200
      shadow-md text-xl flex flex-col justify-center font-oswald " <> @rest[:class]}
      {Map.delete(@rest, :class)}
    >
      <header class="text-xs flex-none self-start invisible bg-orange-300">
        <%= if @guessers != nil do %>
          <%= for g <- @guessers do %>
            <img class="w-5 h-5 inline" src={"/images/" <> g} />
          <% end %>
        <% else %>
          <div class="invisible">"t"</div>
        <% end %>
      </header>

      <div class="flex-auto self-center"><%= @item %></div>

      <footer class="text-xs flex-none self-start">
        <%= if @guessers != nil do %>
          <%= for g <- @guessers do %>
            <img class="w-5 h-5 inline" src={"/images/" <> g} />
          <% end %>
        <% else %>
          <div class="invisible">"t"</div>
        <% end %>
      </footer>
    </button>
    """
  end

#  def render(assigns) do
  #    ~H"""
  #    <div class="grid grid-cols-1 gap-4">
  #      <%= for word <- @words do %>
  #        <%= if @phase != "final" do %>
  #          <!-- put active stuff in function -->
  #          <.render_word
  #            word={word}
  #            guessers={[]}
  #            active={
  #              if @phase == "guesses" and @role == "guesser" do
  #                []
  #              else
  #                [{"disabled", "true"}]
  #              end
  #            }
  #          />
  #        <% else %>
  #          <.render_word
  #            word={word}
  #            guessers={
  #              Enum.into(
  #                Map.keys(Map.filter(@guesses, &Enum.member?(elem(&1, 1), word))),
  #                [],
  #                &@names[&1]
  #              )
  #            }
  #            active={[{"disabled", "true"}]}
  #          />
  #        <% end %>
  #      <% end %>
  #    </div>
  #    """
  #  end

  # TODO: do this better as well
  defp render_word(assigns) do
    ~H"""
    <button
      class="rounded-lg bg-slate-50 h-24 border-gray-200
      shadow-md block p-12 text-2xl flex flex-col font-oswald"
      phx-click="submit_guess"
      value={@word}
      {@active}
    >
      <div class="flex-auto"><%= @word %></div>

      <footer class="text-sm flex-none">
        <%= if @guessers != [] do %>
          <%= for g <- @guessers do %>
            <%= g %>
          <% end %>
        <% end %>
      </footer>
    </button>
    """
  end
end
