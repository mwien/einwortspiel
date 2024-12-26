defmodule Einwortspiel.Game do
  use GenServer
  alias Einwortspiel.Game.{State, View}
  alias Einwortspiel.Notifier

  def child_spec(init_args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, init_args},
      restart: :transient
    }
  end

  def start_link(room_id, options) do
    GenServer.start_link(__MODULE__, [room_id, options],
      name: Einwortspiel.Application.room_via_tuple(room_id)
    )
  end

  def init([room_id, options]) do
    {:ok, State.init(room_id, options)}
  end

  def get_game_view(room_id) do
    case service_name(room_id) do
      nil -> {:error, :invalid_room_id}
      pid -> GenServer.call(pid, {:get_game_view})
    end
  end

  # have join room in future -> and then enter game or something
  def join(room_id, player_id, name) do
    case service_name(room_id) do
      nil -> {:error, :invalid_room_id}
      pid -> GenServer.call(pid, {:join, player_id, name})
    end
  end

  def start_round(room_id, player_id) do
    case service_name(room_id) do
      nil -> {:error, :invalid_room_id}
      pid -> GenServer.call(pid, {:start_round, player_id})
    end
  end

  def submit_clue(room_id, player_id, clue) do
    case service_name(room_id) do
      nil -> {:error, :invalid_room_id}
      pid -> GenServer.call(pid, {:submit_clue, player_id, clue})
    end
  end

  def submit_guess(room_id, player_id, guess) do
    case service_name(room_id) do
      nil -> {:error, :invalid_room_id}
      pid -> GenServer.call(pid, {:submit_guess, player_id, guess})
    end
  end

  def handle_call({:get_game_view}, _from, state) do
    {:reply, {:ok, View.get_view(state)}, state}
  end

  def handle_call({:join, player_id, name}, _from, state) do
    case State.add_player(state, player_id, name) do
      {:ok, {update, new_state}} -> {:reply, :ok, publish_update(new_state, update)}
      {:error, error} -> {:reply, {:error, error}, state}
    end
  end

  def handle_call({:start_round, player_id}, _from, state) do
    case State.start_round(state, player_id) do
      {:ok, {update, new_state}} -> {:reply, :ok, publish_update(new_state, update)}
      {:error, error} -> {:reply, {:error, error}, state}
    end
  end

  def handle_call({:submit_clue, player_id, clue}, _from, state) do
    case State.submit_clue(state, player_id, clue) do
      {:ok, {update, new_state}} -> {:reply, :ok, publish_update(new_state, update)}
      {:error, error} -> {:reply, {:error, error}, state}
    end
  end

  def handle_call({:submit_guess, player_id, guess}, _from, state) do
    case State.submit_guess(state, player_id, guess) do
      {:ok, {update, new_state}} -> {:reply, :ok, publish_update(new_state, update)}
      {:error, error} -> {:reply, {:error, error}, state}
    end
  end

  defp publish_update(state, update) do
    Notifier.publish_game_info(state.id, {:update, update})
    state
  end

  defp service_name(table_id) do
    GenServer.whereis(Einwortspiel.Application.room_via_tuple(table_id))
  end
end
