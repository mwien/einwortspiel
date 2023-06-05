defmodule LostinwordsWeb.GameLive.Standings do
  use Phoenix.Component

  alias LostinwordsWeb.Helpers

 #   <%= if @animals[player_id] != nil do %>
 #     <img class="h-5 w-5 inline" src={"/images/" <> @animals[player_id]}/>
 #     <% else %>
 #      <span> </span>
 #   <% end %>
      #<img class="block w-max" src={"/images/" <> @animals[player_id]}/>
  def render(assigns) do
    IO.inspect(assigns.animals)
    IO.inspect(assigns.animals[assigns.player_id])
    IO.inspect(assigns.player_id)
    IO.inspect("HI")
    ~H"""
    <LostinwordsWeb.CoreComponents.table id="standings" rows={Map.keys(@scores)}>
    <:col :let={player_id} label="">
    <div class="w-6 h-full">
      <img class="w-6 h-6" src={"/images/" <> @animals[player_id]} :if={@animals[player_id] != nil}/>
      </div>
      </:col>
      <:col :let={player_id} label="Player">
        <.name_entry this_player={player_id == @player_id} name={@names[player_id]} inactive={!Enum.member?(@active_players, player_id)} />
      </:col>
      <:col :let={player_id} label="Score"><%= @scores[player_id] %></:col>
    </LostinwordsWeb.CoreComponents.table>
    """
  end

  # <table class="table-auto">
  #      <thead>
  #        <tr>
  #          <th>Name</th>
  #          <th>Score</th>
  #        </tr>
  #      </thead>
  #      <tbody>
  #        <%= for {player_id, player_score} <- @scores do %>
  #          <.render_playerscore this_player={player_id == @player_id} name={@names[player_id]} score={player_score} />
  #        <% end %>
  #      </tbody>
  #    </table>

  # understand how slots work
  defp name_entry(assigns) do
    ~H"""
    <%= if @this_player do %>
      <Helpers.render_textform id="changename" submit_handler="set_name" value={@name} />
    <% else %>
      <span class={"p-3 " <> 
        if @inactive do
          "text-gray-400"
        else
          " "
        end
      }>
        <%= @name %>
      </span>
    <% end %>
    """
  end

  # defp render_playerscore(assigns) do
  #   ~H"""
  #   <tr>
  #     <td>
  #     <%= if @this_player do %>
  #       <Helpers.render_textform id="changename" submit_handler="set_name" value={@name} />
  #     <% else %>
  #       <%=@name %>
  #     <% end %>
  #     </td>
  #     <td>
  #     <%=@score %>
  #     </td>
  #   </tr>
  #   """
  # end
end
