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

  # words 
  # [{word1, false}, {word2, true}, {word3, false}]

  # maybe add local state modules to make this clear???

  # after state change function return
  # {notifications, new_state}
  # game_server can then emit notifications and replace the state 

  # notifications is a list 
  # notifications are of the following form: 
  # {:update_player, player_id, player}
  # {:update_info, info}

  defstruct [
    :id,
    # or info? don't overuse state
    :info,
    :players,
    :round,
    :changed
  ]

  def init(_options) do
    %Game{
      id: Generator.gen_id(),
      info: Info.init(),
      players: %{},
      round: Round.init(),
      changed: []
    }
  end

  def get_info(game) do
    # TODO: change
    game.id
  end

  def get_player(_game) do
    
  end

  def get_players(game) do
    # later this will be more complex and also include round information
    game.players
  end

  def has_player?(game, player_id) do
    Map.has_key?(game.players, player_id)
  end

  def add_player(game, player_id, name) do
    # do Player.create_player(name)
    %Game{game | players: Map.put(game.players, player_id, name)}
    |> add_changed(player_id)
    |> handle_update()
  end

  # also have {:ok, ...} and {:error, ...}

  # round returns changed mapset!!!
  # includes player_ids or atom :info 
  # then handle_update lists out the notifications by calling get_player/get_info

  ################################## TODODODODOODTTODO #####################
  # TODO: -> add changed into game.changed and update game and call handle_update(game)
  def start_round(game, _player_id) do
    Round.start(game.round)
    |> handle_update(game)
  end

  # TODO: add submit_clue submit_guess etc 
  def submit_clue(game, player_id, clue) do
    Round.make_move(game.round, player_id, {:submit_clue, clue})
    |> handle_update(game)
  end

  def submit_guess(game, player_id, guess) do
    Round.make_move(game.round, player_id, {:submit_guess, guess})
    |> handle_update(game)
  end
end
