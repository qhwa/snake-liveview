# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :snake, SnakeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jeeYrMz4lasI0LqnwArv58V4UQvef0qOofyoyDna7bA3/Z4pz71nfI9TbNgNNtKt",
  render_errors: [view: SnakeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Snake.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "ElS6VY0gaLG1sn5bTF/YRGGFTSCtKzaI"],
  template_engines: [leex: Phoenix.LiveView.Engine]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
