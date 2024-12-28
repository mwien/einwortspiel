defmodule EinwortspielWeb.GameLive.Ingame do
  use EinwortspielWeb, :html

  alias EinwortspielWeb.GameLive.PlayerComponent

  attr :player_id, :string
  attr :general, :map
  attr :players, :map

  def render(assigns) do
    ~H"""
    <.header>
      <div class="flex items-center">
        <.button
          :if={@general.can_start_round and @general.phase == :init}
          phx-click="start_round"
          class="px-1 py-0.5 m-1"
        >
          Start
        </.button>
        <.button
          :if={@general.can_start_round and @general.phase != :init}
          phx-click="start_round"
          class="px-1 py-0.5 m-1"
        >
          Next
        </.button>
        <div class="flex items-center mx-1">
          <div class="px-1 py-0.5 bg-green-300 rounded-sm ring ring-violet-700 m-1">
            <%= @general.wins %>
          </div>
          <div class="px-1 py-0.5 bg-red-400 rounded-sm ring ring-violet-700 m-1">
            <%= @general.losses %>
          </div>
        </div>
      </div>
    </.header>
    <.main>
      <.box class="mt-2 mb-4 text-center p-1">
        <div :if={@general.phase == :init} class="flex flex-row justify-between items-center">
          <div class="w-24" />
          <div class="w-1/2">
            <p :if={!@general.can_start_round and @general.phase == :init} class="m-1">
              Waiting for second player
              <.icon
                name="hero-ellipsis-horizontal"
                class="ml-1.5 w-5 h-5 duration-2000 animate-bounce"
              />
            </p>
            <p :if={@general.can_start_round and @general.phase == :init} class="m-1">
              Ready to start <.icon name="hero-check-circle" class="ml-1.5 w-5 h-5" />
            </p>
            <p :if={@general.phase == :init} class="m-1">
              Share the url to invite further players
              <.button phx-click={JS.dispatch("urlcopy")} class="my-1 ml-1 px-1.5 pb-0.5 group">
                <.icon name="hero-clipboard-document" class="w-5 h-5 group-focus:hidden" />
                <.icon
                  name="hero-clipboard-document-check"
                  class="w-5 h-5 hidden group-focus:inline-block"
                />
              </.button>
            </p>
          </div>
          <div id="qrcode" phx-hook="GenQR" class="w-32 m-1"></div>
        </div>
        <div :if={@general.phase != :init}>
          <p class="m-1">
            <%= render_info(@general.phase) %>
          </p>
        </div>
      </.box>
      <.live_component
        module={PlayerComponent}
        id={@player_id}
        player={@players[@player_id]}
        this_player={true}
        spectating={false}
        phase={@general.phase}
      />
      <.live_component
        :for={{player_id, player} <- @players}
        :if={player_id != @player_id and @players[player_id].words != nil}
        module={PlayerComponent}
        id={player_id}
        player={player}
        this_player={false}
        spectating={@players[@player_id].words == nil}
        phase={@general.phase}
      />
      <.live_component
        :for={{player_id, player} <- @players}
        :if={player_id != @player_id and @players[player_id].words == nil}
        module={PlayerComponent}
        id={player_id}
        player={player}
        this_player={false}
        spectating={false}
        phase={@general.phase}
      />
    </.main>
    """
  end

  defp render_info(round_phase) do
    case round_phase do
      :clues -> "Describe your words with one clue!"
      :guesses -> "Guess the word that is unique to you!"
      :win -> "You win the round!"
      :loss -> "You lose the round!"
    end
  end
end
