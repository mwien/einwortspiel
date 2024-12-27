defmodule Einwortspiel.Game.View do
  alias __MODULE__
  alias Einwortspiel.Game.{Info, Player, Round, State, Words}

  # add further typespecs for general and player -> maybe in submodules?
  defstruct [
    :general,
    :players
  ]

  def get_view(state) do
    %View{general: get_general(state), players: get_players(state)}
  end

  defp get_general(%State{round: nil} = state) do
    %{
      can_start_round: if(State.can_start_round(state) == :ok, do: true, else: false),
      phase: :init,
      wins: 0,
      losses: 0
    }
  end

  defp get_general(state) do
    %{
      can_start_round: if(State.can_start_round(state) == :ok, do: true, else: false),
      phase: Round.get_phase(state.round),
      wins: Info.get_wins(state.info),
      losses: Info.get_losses(state.info)
    }
  end

  defp get_player(state, player_id) do
    name = Player.get_name(state.players[player_id])
    connected = Player.get_connected(state.players[player_id])
    active = Player.get_active(state.players[player_id])

    if state.round == nil or !Round.has_player?(state.round, player_id) do
      %{name: name, connected: connected, active: active, words: nil, clue: nil, guess: nil}
    else
      %{
        name: name,
        connected: connected,
        active: active,
        words: word_view(state, player_id),
        clue: Round.get_clue(state.round, player_id),
        guess: Round.get_guess(state.round, player_id)
      }
    end
  end

  defp get_players(state) do
    Enum.reduce(Map.keys(state.players), %{}, &Map.put(&2, &1, get_player(state, &1)))
  end

  def update_general(new_state, old_state) do
    put_in(
      new_state.update.general,
      filter_changed(get_general(new_state), get_general(old_state))
    )
  end

  def update_player(new_state, old_state, player_id) do
    put_in(
      new_state.update.players[player_id],
      filter_changed(get_player(new_state, player_id), get_player(old_state, player_id))
    )
  end

  def update_new_player(state, player_id) do
    put_in(
      state.update.players[player_id],
      get_player(state, player_id)
    )
  end

  defp filter_changed(map1, map2) do
    Map.filter(map1, fn {k, v} -> v != map2[k] end)
  end

  defp word_view(state, player_id) do
    words = Round.get_words(state.round)
    extraword = Words.get_extraword(words, player_id)

    Words.get_words(words, player_id)
    |> Enum.map(fn word -> {word, word == extraword} end)
  end
end
