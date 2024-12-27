defmodule EinwortspielWeb.RoomController do
  use EinwortspielWeb, :controller

  def create(conn, params) do
    room_id = Einwortspiel.Rooms.open_room(%{language: params["language"]})
    redirect(conn, to: "/#{room_id}")
  end
end
