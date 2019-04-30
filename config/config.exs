# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :brigade_rest, BrigadeRestWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "n9fQskSr9zYgzDg5a8OxnUsJPh+EUEbvle61zm0AVbHoOPl38TU0zKJ4J/5S4jdt",
  render_errors: [view: BrigadeRestWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BrigadeRest.PubSub,
           adapter: Phoenix.PubSub.PG2],
  # The allowed_api_keys are used by the SimpleApiKeyAuthPlug module to determine if an HTTP
  # request should be allowed access to the rest api method, or not - this can be generated another
  # way but for now this is the easiest way to provide simple access.
  allowed_api_keys: [
    # Put in any allowed keys required here, should be strings probably 32-char in length or more
    # You can generate one with `mix phx.gen.secret` if required
    # E.g.
    # "ds8v57kheeod+cLXz7HeTOdfjitu9xjruAf4rF9DjjzcqmOMZdeP+k7bVN0vQGMX"
  ]

# The config namespaces (:brigade_rest, :thrift_service), ... etc are just arbirtary namespaces
# created to contain information about the thrift servers that the clients will be able to
# connect to. Since the ports ought to remain the same they are included in the `config.exs`
# and the `host` is provided as the `staging` defaults. The `prod.exs` config file contains the
# production hosts for the thrift services. To enable the production values, run the service
# with `MIX_ENV=prod`
config :brigade_rest, :thrift_service,
  host: "localhost",
  port: 9095

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
