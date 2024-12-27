defmodule Einwortspiel.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EinwortspielWeb.Telemetry,
      {Phoenix.PubSub, name: Einwortspiel.PubSub},
      Einwortspiel.Rooms.Presence,
      {Finch, name: Einwortspiel.Finch},
      EinwortspielWeb.Endpoint,
      {Registry, keys: :unique, name: Einwortspiel.Registry},
      Einwortspiel.Rooms
    ]

    opts = [strategy: :one_for_one, name: Einwortspiel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    EinwortspielWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def via_tuple(name) do
    {:via, Registry, {Einwortspiel.Registry, name}}
  end
end
