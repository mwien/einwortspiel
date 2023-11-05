defmodule LostinwordsWeb.GameLive.Spectator do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
      <div class="flex flex-col items-center">  
        <div class="my-4" > You are currently in spectator mode. Click here to </div>
        <LostinwordsWeb.CoreComponents.button phx-click="leave_spectator" >
          Join 
        </LostinwordsWeb.CoreComponents.button>
      </div>
    """
  end
end
