defmodule LostinwordsWeb.TableController do
  use LostinwordsWeb, :controller

  def create(conn, _params) do
    table_id = Lostinwords.Game.open_table()

    conn
    # use path helpers
    |> redirect(to: "/#{table_id}")
  end
end
