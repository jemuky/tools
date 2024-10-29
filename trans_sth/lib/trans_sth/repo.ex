defmodule TransSth.Repo do
  use Ecto.Repo,
    otp_app: :trans_sth,
    adapter: Ecto.Adapters.Postgres
end
