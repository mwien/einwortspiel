defmodule EinwortspielWeb.TableController do
  use EinwortspielWeb, :controller

  def create(conn, _params) do
    table_id = Einwortspiel.Game.open_table()

    conn
    # use path helpers
    |> redirect(to: "/#{table_id}")
  end
end
