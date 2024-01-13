defmodule EinwortspielWeb.GameLive.Main do
  use EinwortspielWeb, :html

  alias EinwortspielWeb.GameLive.PlayerComponent
  alias Phoenix.LiveView.JS
  
  attr :round, Einwortspiel.Game.Round
  attr :state, Einwortspiel.Game.TableState
  attr :player_id, :string
  attr :players, :map

  # TODO: allow players to leave 
  # -> this makes logic a bit more complex
  def render(assigns) do
    ~H"""
    <main class="flex flex-col items-center w-11/12 lg:w-3/5 2xl:w-1/2 mx-auto"> 
      <div :if={!Map.has_key?(@players, @player_id)}> 
        <div class="my-4" > Click below to </div>
        <EinwortspielWeb.CoreComponents.button phx-click="join" class="my-4 py-1.5 px-2" >
          Join
        </EinwortspielWeb.CoreComponents.button>
      </div>
      <div :if={Map.has_key?(@players, @player_id) and @round == nil}> 
        <div class="m-4" :if={map_size(@players) < 2}> 
          Waiting for second player to join
          <Heroicons.ellipsis_horizontal class="ml-1.5 w-6 h-6 inline
                    duration-2000
                    animate-bounce"
          />
        </div>
        <div class="m-4" :if={map_size(Map.filter(@players, fn {_, player} -> player.active end)) >= 2}> 
          Ready to start
          <Heroicons.check_circle class="ml-1 w-6 h-6 inline" />
        </div>
      </div>
      <!-- also have player component when there is no current round -->
      <div :if={Map.has_key?(@players, @player_id) and @round != nil}>
        <PlayerComponent.ingame 
          player={@players[@player_id]}
          commonwords={@round.commonwords}
          extraword={@round.extrawords[@player_id]}
          shuffle={@round.shuffle[@player_id]}
          clue={Map.get(@round.clues, @player_id, "")}
          guess={Map.get(@round.guesses, @player_id, "")}
          thisplayer={true}
          phase={@round.phase}
        /> 
        <PlayerComponent.ingame 
          player={@players[player]}
          commonwords={@round.commonwords}
          extraword={@round.extrawords[player]}
          shuffle={@round.shuffle[player]}
          clue={Map.get(@round.clues, player, "")}
          guess={Map.get(@round.guesses, player, "")}
          thisplayer={false}
          phase={@round.phase}
          :for={player <- Map.keys(@players)}
          :if={player != @player_id}
        />
      </div>
    </main>
    """
  end


  #def main(assigns) do
#  ~H"""
#    <main class="w-full">
#      <div class="flex flex-col items-center my-6" :if={@state.phase == :init}> 
#        <%= if length(Map.keys(Map.filter(@players, fn {_, value} -> !value.spectator end))) < 2 do %>
#          <div class="m-4">
#          <%= "Waiting for second player to join" %> 
#          <Heroicons.ellipsis_horizontal class="ml-1.5 w-6 h-6 inline
#                    duration-2000
#                    animate-bounce"
#          />
#          </div>
#        <% else %> 
#          <div class="m-4">
#          <%= "Ready to start" %>
#          <Heroicons.check_circle class="ml-1 w-6 h-6 inline" />
#          </div>
#        <% end %>
#          <div class="m-4">
#          <%= "Copy URL " %>
#          <EinwortspielWeb.CoreComponents.button phx-click={JS.dispatch("urlcopy")} class="focus:ring-1 focus:ring-violet-500 ml-1.5 focus:fill-violet-700 px-2 py-2">  
#            <svg height="21" width="21" version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 360 360">
#              <path d="M318.54,57.282h-47.652V15c0-8.284-6.716-15-15-15H34.264c-8.284,0-15,6.716-15,15v265.522c0,8.284,6.716,15,15,15h47.651
#                    v42.281c0,8.284,6.716,15,15,15H318.54c8.284,0,15-6.716,15-15V72.282C333.54,63.998,326.824,57.282,318.54,57.282z
#                    M49.264,265.522V30h191.623v27.282H96.916c-8.284,0-15,6.716-15,15v193.24H49.264z M303.54,322.804H111.916V87.282H303.54V322.804z"/>
#            </svg>
#          </EinwortspielWeb.CoreComponents.button>
#
#          </div>
#      </div>
#
#      <div id="game" class="my-10" :if={@state.phase != :init}> 
#        <div class="bg-violet-200 py-2 rounded-sm shadow-md" :if={Map.has_key??(@round.extrawords, @player_id)} >
#        <div class="flex justify-center my-4" :if={Map.has_key??(@round.extrawords, @player_id)} > 
#          <Heroicons.ellipsis_horizontal class="mr-1 w-6 h-6 inline
#                    duration-2000
#                    animate-bounce" :if={(@round.phase == :clues and get_clue_for_player(@round.clues, @player_id) == "") or (@round.phase == :guesses and @round.guesses[@player_id] == nil)} />  
#          <Heroicons.check_circle class="mr-1 w-6 h-6 inline" :if={(@round.phase == :clues and get_clue_for_player(@round.clues, @player_id) != "") or (@round.phase == :guesses and @round.guesses[@player_id] != nil)} />
#          <%= case @round.phase do 
#            :clues -> "Describe your words with one clue."
#            :guesses -> "Guess the word that only you have."
#            _ -> "You " <> if @round.guesses == @round.extrawords do "win" else "lose" end  <> " the round."
#          end
#          %>
#        </div>
#        <div class="my-8">
#        <Words.render words={get_words_for_player(@round.commonwords, @round.extrawords, @round.shuffle, @player_id)} active={@round.phase == :guesses and @round.guesses[@player_id] == nil} correctword={@round.extrawords[@player_id]} guess={@round.guesses[@player_id]} show = {@round.guesses[@player_id] != nil} :if={Map.has_key??(@round.extrawords, @player_id)} />
#        </div>
#        <div class="my-4">
#        <Clue.render clue={get_clue_for_player(@round.clues, @player_id)} active={@round.phase == :clues} :if={Map.has_key??(@round.extrawords, @player_id)} />
#        </div>
#        </div>
#        <div class="flex justify-center my-10 bg-violet-200 py-8 rounded-sm shadow-md" :if={!Map.has_key??(@round.extrawords, @player_id)} > 
#          You will join starting with the next round. For now you can spectate the current round.  
#        </div>
#        <div class="mt-16">
#        <div class="bg-violet-200 py-2 rounded-sm shadow-md">
#        <Others.render player_id={@player_id} players={Map.filter(@players, fn{key, value} -> Map.has_key??(@round.extrawords, key) and value.spectator == false end)} commonwords = {@round.commonwords} extrawords = {@round.extrawords} shuffle={@round.shuffle} clues = {@round.clues} guesses = {@round.guesses} phase = {@round.phase} />
#        </div>
#        </div>
#      </div>
#    </main>
#    """
#  end
#
  defp get_words_for_player(player_id, commonwords, extrawords, shuffle) do
    [extrawords[player_id] | commonwords] 
    |> Enum.zip(shuffle[player_id])
    |> List.keysort(1)
    |> Enum.unzip()
    |> elem(0)
  end

  defp get_clue_for_player(player_id, clues) do
    Map.get(clues, player_id, "")
  end
end
