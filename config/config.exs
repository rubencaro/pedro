# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :pedro, Pedro.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "LD9PWAP5gVenCU39R59vc6LcK5OE6ZSCmuPTfnyIZwNFLisPQlcNfU1jF9kC38eO",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Pedro.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :pedro,
  dispatcher: [pools: [[worker_opts: [adapter: Pedro.Adapter],
                        pool_opts: [name: {:local, Pedro.Dispatcher.Pool1},
                                    size: 5,
                                    max_overflow: 10]]]]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  utc_log: true

config :cipher, keyphrase: "testiekeyphraseforcipher",
              ivphrase: "testieivphraseforcipher",
              magic_token: "magictoken"

config :mnesia, dir: 'data/'

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
