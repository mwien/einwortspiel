defmodule EinwortspielWeb.GameController do
  use EinwortspielWeb, :controller

  def create(conn, params) do
    game_id = Einwortspiel.GameSupervisor.open_game(%{language: params["language"]})
    redirect(conn, to: "/#{game_id}")
  end
end
