defmodule EinwortspielWeb.GameLive.Chat do
  use EinwortspielWeb, :html

  def render(assigns) do
    ~H"""
    <.box class="mt-8">
      <div :for={{player_id, message} <- Enum.reverse(@messages)} class="ml-2">
        <span class="min-w-32 inline-block"><%= @players[player_id].name %>:</span>
        <span><%= message %></span>
      </div>
      <div class="mt-6 mb-2 flex justify-center">
        <.textform
          id="chat"
          label="Message"
          form={to_form(%{})}
          submit_handler="submit_chat_message"
          class="w-8/12 md:w-7/12 lg:w-6/12"
        />
      </div>
    </.box>
    """
  end
end
