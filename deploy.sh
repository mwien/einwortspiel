mix deps.get
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
PORT=4001 MIX_ENV=prod elixir --erl "-detached" -S mix phx.server
