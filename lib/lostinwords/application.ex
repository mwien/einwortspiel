defmodule Lostinwords.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LostinwordsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Lostinwords.PubSub},
      # Start the Presence system
      Lostinwords.Presence,
      # Start Finch
      {Finch, name: Lostinwords.Finch},
      # Start the Endpoint (http/https)
      LostinwordsWeb.Endpoint,
      # Start a worker by calling: Lostinwords.Worker.start_link(arg)
      # {Lostinwords.Worker, arg}
      {Registry, keys: :unique, name: Lostinwords.Game.Registry},
      Lostinwords.Game.TableSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lostinwords.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LostinwordsWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def via_tuple(name) do
    {:via, Registry, {Lostinwords.Game.Registry, name}}
  end
end
