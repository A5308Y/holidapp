defmodule Holidapp.Repo do
  use Ecto.Repo,
    otp_app: :holidapp,
    adapter: Ecto.Adapters.Postgres
end
