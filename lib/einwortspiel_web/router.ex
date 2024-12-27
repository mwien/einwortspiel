defmodule EinwortspielWeb.Router do
  use EinwortspielWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {EinwortspielWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EinwortspielWeb do
    pipe_through :browser

    get "/", LobbyController, :index

    post "/room/create", RoomController, :create

    live "/:room_id", GameLive
  end

  if Application.compile_env(:einwortspiel, :dev_routes) do
    # if used in production dashboard should be admin-only
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EinwortspielWeb.Telemetry
      # forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  defp fetch_current_user(conn, _) do
    case get_session(conn, :user_id) do
      nil ->
        put_session(conn, :user_id, Einwortspiel.Generator.gen_id())

      _user_id ->
        conn
    end
  end
end
