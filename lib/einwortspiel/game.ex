defmodule Einwortspiel.Game do
  alias __MODULE__
  alias Einwortspiel.Generator
  alias Einwortspiel.Game.{Round, Info}

  # specify exactly how info and player are presented to the outside!
  # each field and entry etc!

  # info
  # %{
  #   can_start_round?,
  #   phase,
  #   last_result, :win or :loss
  #   wins,
  #   losses
  # }
  # phase is :pre_round, :clues, :guesses, :post_round

  # players
  # %{
  #   player_id => player
  # }

  # player 
  # %{
  #   id,
  #   words, 
  #   clue, 
  #   guess,
  #   connected,
  #   active
  # }

  # maybe add local state modules to make this clear???

  # after state change function return
  # {notifications, new_state}
  # game_server can then emit notifications and replace the state 

  # notifications is a list 
  # notifications are of the following form: 
  # {:new_player, player_id, player}
  # {:update_player, player_id, field, value}
  # {:update_info, field, value}

  defstruct [
    :id,
    :info, # or info? don't overuse state
    :players,
    :round
  ]

  def init(_options) do
    %Game{
      id: Generator.gen_id(),
      info: Info.init(),
      players: %{},
      round: Round.init()
    }
  end

  def get_info(game) do
    # TODO: change
    game.id
  end

  def get_players(game) do
    # later this will be more complex and also include round information
    game.players
  end

  def has_player?(game, player_id) do
    Map.has_key?(game.players, player_id)
  end

  def add_player(game, player_id, name) do
    # replace by Player.create_player(name)
    new_player = name
    {[{:new_player, player_id, new_player}] ,%Game{game | players: Map.put(game.players, player_id, new_player)}}
  end

  # also have {:ok, ...} and {:error, ...}

  def start_round(game, _player_id) do
    {round_notifications, round} = Round.start(game.round)
    # TODO: this gives notifications for Info update thingy
    {info_notifications, info} = Info.update(game.info, :phase, :in_game) # is that okay to push like this -> or put this as event
    {info_notifications ++ round_notifications, %Game{game | round: round, info: info}}
  end

  # TODO: add submit_clue submit_guess etc 
  def submit_clue(game, player_id, clue) do
    {notifications, round} = Round.make_move(game.round, player_id, {:submit_clue, clue})
    # notifications are not relevant for game as e.g. in submit_guess
    {notifications, %Game{game | round: round}}
  end

  def submit_guess(game, player_id, guess) do
    Round.make_move(game.round, player_id, {:submit_guess, guess})
    |> handle_update(game)
  end

  # -> this also necessitates info change notifications
  defp handle_update({round, notifications}, game) do
    # TODO: go through notifications for end_of_round signal and win/loss
    {notifications, %Game{game | round: round}}
  end
end
