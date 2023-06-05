defmodule LostinwordsWeb.LobbyController do
  use LostinwordsWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
