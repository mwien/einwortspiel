defmodule Einwortspiel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      EinwortspielWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Einwortspiel.PubSub},
      # Start the Presence system
      Einwortspiel.Presence,
      # Start Finch
      {Finch, name: Einwortspiel.Finch},
      # Start the Endpoint (http/https)
      EinwortspielWeb.Endpoint,
      # Start a worker by calling: Einwortspiel.Worker.start_link(arg)
      # {Einwortspiel.Worker, arg}
      {Registry, keys: :unique, name: Einwortspiel.Game.Registry},
      Einwortspiel.Game.TableSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Einwortspiel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EinwortspielWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def via_tuple(name) do
    {:via, Registry, {Einwortspiel.Game.Registry, name}}
  end
end
