defmodule Einwortspiel.Game do
  alias __MODULE__
  alias Einwortspiel.Game.{Info, Player, Round, Settings}
  alias Einwortspiel.GameView

  defstruct [
    :id,
    :info,
    :players,
    :round,
    :settings,
    :update
  ]

  def init(game_id, options) do
    %Game{
      id: game_id,
      info: Info.init(),
      players: %{},
      round: nil,
      settings: Settings.init(options),
      update: %GameView{general: %{}, players: %{}}
    }
  end

  def add_player(game, player_id, name) do
    if has_player?(game, player_id) do
      {:error, :player_id_exists}
    else
      {:ok,
       %Game{game | players: Map.put(game.players, player_id, Player.create(name))}
       |> GameView.update_new_player(player_id)
       |> GameView.update_general(game)
       |> emit_update()}
    end
  end

  def start_round(game, _player_id) do
    case can_start_round(game) do
      :ok ->
        new_game = %Game{game | round: Round.init(Map.keys(game.players), game.settings)}
        {:ok, {GameView.get_game_view(new_game), new_game}}

      {:error, error} ->
        {:error, error}
    end
  end

  def submit_clue(game, player_id, clue) do
    case Round.make_move(game.round, player_id, {:submit_clue, clue}) do
      {:ok, new_round} ->
        {:ok,
         %Game{game | round: new_round}
         |> GameView.update_player(game, player_id)
         |> GameView.update_general(game)
         |> emit_update()}

      {:error, error} ->
        {:error, error}
    end
  end

  def submit_guess(game, player_id, guess) do
    case Round.make_move(game.round, player_id, {:submit_guess, guess}) do
      {:ok, new_round} ->
        {:ok,
         %Game{
           game
           | round: new_round,
             info: Info.evaluate_result(game.info, Round.get_phase(new_round))
         }
         |> GameView.update_player(game, player_id)
         |> GameView.update_general(game)
         |> emit_update()}

      {:error, error} ->
        {:error, error}
    end
  end

  # take only active players into account
  def can_start_round(game) do
    cond do
      map_size(game.players) < 2 -> {:error, :too_few_players}
      game.round == nil -> :ok
      Enum.member?([:clues, :guesses], Round.get_phase(game.round)) -> {:error, :ongoing_round}
      true -> :ok
    end
  end

  defp has_player?(game, player_id) do
    Map.has_key?(game.players, player_id)
  end

  defp emit_update(game) do
    {game.update, %Game{game | update: %GameView{general: %{}, players: %{}}}}
  end
end
