defmodule EinwortspielWeb.LobbyController do
  use EinwortspielWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
