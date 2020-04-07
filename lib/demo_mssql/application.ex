defmodule DemoMssql.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      DemoMssql.Repo,
      # Start the Telemetry supervisor
      DemoMssqlWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: DemoMssql.PubSub},
      # Start the Endpoint (http/https)
      DemoMssqlWeb.Endpoint
      # Start a worker by calling: DemoMssql.Worker.start_link(arg)
      # {DemoMssql.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DemoMssql.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DemoMssqlWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
