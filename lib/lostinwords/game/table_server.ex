defmodule Lostinwords.Game.TableServer do
  use GenServer
  alias Lostinwords.Game.Table

  def child_spec(table) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [table]},
      restart: :transient
    }
  end

  def start_link(table) do
    GenServer.start_link(__MODULE__, table, name: via_tuple(table.table_id))
  end

  def start_round(table_id) do
    GenServer.call(service_name(table_id), {:start_round})
  end

  def move(table_id, player_id, move) do
    GenServer.call(service_name(table_id), {:move, player_id, move})
  end

  def join(table_id, player_id) do
    GenServer.call(service_name(table_id), {:join, player_id})
  end

  def set_name(table_id, player_id, name) do
    GenServer.call(service_name(table_id), {:set_name, player_id, name})
  end

  def force_continue(table_id) do
    GenServer.call(service_name(table_id), {:continue})
  end

  def init(table) do
    Phoenix.PubSub.subscribe(Lostinwords.PubSub, "table:#{table.table_id}")
    {:ok, table}
  end

  # TODO: REMOVE DUPLICATE CODE
  # also in init!
  # check whether there are issues (player being added twice and then not deleted twice)
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, table) do
    {:noreply, Table.update_active_players(table, joins, leaves)
    |> handle_update()}
  end

  def handle_call({:start_round}, _from, state) do
    {:reply, :ok,
     Table.start_round(state)
     |> IO.inspect()
     |> handle_update()}
  end

  def handle_call({:move, player_id, move}, _from, state) do
    {:reply, :ok,
     Table.move(state, player_id, move)
     |> handle_update()}
  end

  def handle_call({:join, player_id}, _from, state) do
    afterjoin =
      Table.join(state, player_id)
      |> handle_update()
    
    {name, animal} = Lostinwords.Generator.gen_animal()

    aftername = 
      if !Map.has_key?(afterjoin.names, player_id) do
        Table.set_name(afterjoin, player_id, name)
        |> handle_update()
      else
        afterjoin
      end
  
    # repetitive code TODO
    afteranimal = 
      if !Map.has_key?(aftername.animals, player_id) do
        Table.set_animal(aftername, player_id, animal)
        |> handle_update()
      else
        aftername
      end

    assigns = Table.construct_assigns(afteranimal, player_id)
    {:reply, assigns, afteranimal}
  end

  def handle_call({:set_name, player_id, name}, _from, state) do
    {:reply, :ok,
     Table.set_name(state, player_id, name)
     |> handle_update()}
  end

  def handle_call({:continue}, _from, state) do
    {:reply, :ok, Table.continue(state)
    |> handle_update()}
  end

  defp handle_update({instructions, new_state}) do
    # use enum reduce because instructions might change state later
    # (currently they don't)
    Enum.reduce(Enum.reverse(instructions), new_state, &handle_instruction(&2, &1))
  end

  defp handle_instruction(new_state, {:notify_player, player_id, instruction_payload}) do
    Lostinwords.Game.PlayerNotifier.publish(new_state.table_id, player_id, instruction_payload)
    new_state
  end

  def service_name(table_id) do
    GenServer.whereis(via_tuple(table_id))
  end

  defp via_tuple(name) do
    {:via, Registry, {Lostinwords.Game.Registry, name}}
  end
end
