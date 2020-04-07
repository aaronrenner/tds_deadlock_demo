use Mix.Config

# Only in tests, remove the complexity from the password encryption algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :demo_mssql, DemoMssql.Repo,
  username: "sa",
  password: "some!Password",
  database: "demo_mssql_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  set_allow_snapshot_isolation: :on

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :demo_mssql, DemoMssqlWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
