# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :holidapp,
  ecto_repos: [Holidapp.Repo]

# Configures the endpoint
config :holidapp, HolidappWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "dl6bFVXzla+oCai/jm0x8hGGJSke0N3Bo360xaq8q9maIloBfDjdgrKLcX+BHjHw",
  render_errors: [view: HolidappWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Holidapp.PubSub,
  live_view: [signing_salt: "l92eSU2f"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
