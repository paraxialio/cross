defmodule Cross.Repo do
  use Ecto.Repo,
    otp_app: :cross,
    adapter: Ecto.Adapters.Postgres
end
