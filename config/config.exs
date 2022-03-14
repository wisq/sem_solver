import Config

config :logger, :console, format: "[$level] $message\n"

import_config "#{Mix.env()}.exs"
