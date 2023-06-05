# Lost In Words

Multiplayer word game using Elixir, Phoenix and Liveview. Currently only a prototype, so there are some bugs and rough edges (e.g., all players need to join before starting the first round for it to work etc)...

The idea of the game is that one player summarizes three given words in one clue word. The other players see the same three words and an extra one (and of course the clue). Their goal is to find out which of the four words was not described by the clue. 

![Alt text](/priv/static/images/README.png?raw=true "Views of the two players (before and after resolution)")      

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
