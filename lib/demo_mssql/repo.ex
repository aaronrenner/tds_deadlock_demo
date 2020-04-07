defmodule DemoMssql.Repo do
  use Ecto.Repo,
    otp_app: :demo_mssql,
    adapter: Ecto.Adapters.Tds
end
