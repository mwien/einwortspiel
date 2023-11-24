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

    post "/table/create", TableController, :create

    live "/:table_id", GameLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", EinwortspielWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EinwortspielWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  defp fetch_current_user(conn, _) do
    case get_session(conn, :user_id) do
      nil ->
        put_session(conn, :user_id, generate_user_id())

      _user_id ->
        conn
    end
  end

  defp generate_user_id() do
    :crypto.strong_rand_bytes(16) |> Base.encode16()
  end
end
