defmodule EinwortspielWeb.GameLive.Header do
  use EinwortspielWeb, :html
  
  alias EinwortspielWeb.GameLive.NextRound
  alias EinwortspielWeb.Helpers

  # TUDU add help and settings (on the right) 
  # <.icon name="hero-question-mark-circle" class="w-5 h-5"/>
  # <.icon name="hero-cog-6-tooth" class="w-5 h-5" />
  # TUDU later: mobile vs pc header
  attr :player_id, :string
  attr :players, :map
  attr :state, :map
  def ingame(assigns) do
    ~H"""
    <.header>
      <h2 class="text-4xl font-bebasneue m-1"> einwortspiel </h2>
      <div class="flex items-center">
        <.inner_box class="">
          <span> 
            <.icon name="hero-plus-circle" class="mb-1"/> 
            <%= @state.wins %> 
          </span> 
          <span> 
            <.icon name="hero-minus-circle" class="mb-1"/> 
            <%= @state.losses %> 
          </span>
        </.inner_box>
        <.nextround state={@state.phase} num_players={map_size(@players)}/>
      </div>
    </.header> 
    """
  end 
  # TODO TODO make function for number of active players!!!!

  # TODO: redo -> does it need to be extra function?
  defp nextround(assigns) do
    ~H"""
    <%= if @state == :end_of_round do %>
      <div id="nextround" class="m-1">
        <EinwortspielWeb.CoreComponents.button phx-click="start_round" class = "px-1 py-0.5">
          Next
        </EinwortspielWeb.CoreComponents.button>
      </div>
    <% end %>
    <%= if @state == :init && @num_players >= 2 do %>
      <div class="m-1">
        <EinwortspielWeb.CoreComponents.button phx-click="start_round" class = "px-1 py-0.5">
          Start
        </EinwortspielWeb.CoreComponents.button>
      </div>
    <% end %>
    <%= if (@state == :init and @num_players < 2) or (@state != :init and @state != :end_of_round ) do %>
      <div class="m-1">
        <EinwortspielWeb.CoreComponents.button phx-click="start_round" {%{disabled: "true"}} class = "px-1 py-0.5">
          Start
        </EinwortspielWeb.CoreComponents.button>
      </div>
    <% end %>
    
    """
  end

end
