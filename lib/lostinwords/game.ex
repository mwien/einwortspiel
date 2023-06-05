defmodule Lostinwords.Game do
  alias Lostinwords.Game.TableServer
  alias Lostinwords.Game.TableSupervisor

  # Client API for the game logic

  def open_table() do
    TableSupervisor.open_table()
  end

  def join(table_id, player_id) do
    TableServer.join(table_id, player_id)
  end

  def set_name(table_id, player_id, name) do
    TableServer.set_name(table_id, player_id, name)
  end

  # after joining, clients get game info via the "user:<user_id>" pubsub channel
  # (other ways of subscribing might be added at some point)
  # the info notifications are as follows:
  # {:info_role, role} emitted at the start of a round indicating the role,
  # which is either "cluer" or "guesser"
  # {:info_words, words} emitted at the start of a round giving the words,
  # which contains a list of strings (cluers see the leftwords, guessers see all)
  # {:info_unauthorized_move} emitted when a move is not legal
  # (e.g. a clue submitted after the clueing phase)
  # {:info_received_clue, player_id} emitted immediately after a clue is submitted,
  # is send to all players
  # {:info_clues, clues} emitted after all clues are submitted, contains a map
  # from player_ids to clues (one clue per player)
  # {:info_received_guess, player_id, success} emitted immediately after a guess
  # is submitted, contains info if guess was successfull (true/false)
  # {:info_finished, player_id} emitted after a player guessed the last lostword
  # or guessed wrongly -> in both cases no more guessing possible,
  # send to all players
  # {:info_score, player_id, plus_score, new_score} emitted after a player made a
  # a guess (correct or incorrect), contains the new score, what score was gained,
  # send to all players
  # {:info_guesses, guesses} emitted after all guesses were made, contains a map
  # from player_ids to guess list
  # (multiple guesses per player possible depending on game setting)

  def start_round(table_id) do
    TableServer.start_round(table_id)
  end

  # possible moves are
  # {:submit_clue, clue}
  # and
  # {:submit_guess, guess}

  def move(table_id, player_id, move) do
    TableServer.move(table_id, player_id, move)
  end

  def force_continue(table_id) do
    TableServer.force_continue(table_id)
  end

end
