defmodule EinwortspielWeb.TableController do
  use EinwortspielWeb, :controller

  def create(conn, params) do
    table_id = Einwortspiel.Game.open_table(%{language: params["language"]})
    redirect(conn, to: "/#{table_id}")
  end
end
