defmodule EinwortspielWeb.TableController do
  use EinwortspielWeb, :controller

  def create(conn, params) do
    IO.inspect(params)
    table_id = Einwortspiel.Game.open_table(%{"language" => params["language"]})

    conn
    # use path helpers
    |> redirect(to: "/#{table_id}")
  end
end
