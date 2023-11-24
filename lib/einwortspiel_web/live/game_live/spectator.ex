defmodule EinwortspielWeb.GameLive.Spectator do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
      <div class="flex flex-col items-center">  
        <div class="my-4" > Click below to </div>
        <EinwortspielWeb.CoreComponents.button phx-click="leave_spectator" >
          Join 
        </EinwortspielWeb.CoreComponents.button>
      </div>
    """
  end
end
