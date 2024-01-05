defmodule EinwortspielWeb.GameLive.Spectator do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
      <div class="flex flex-col items-center my-6">  
        <div class="my-4" > Click below to </div>
        <EinwortspielWeb.CoreComponents.button phx-click="leave_spectator" class="my-4 py-1.5 px-2" >
          Join 
        </EinwortspielWeb.CoreComponents.button>
      </div>
    """
  end
end
