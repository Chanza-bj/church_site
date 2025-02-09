defmodule ChurchSite.Repo do
  use Ecto.Repo,
    otp_app: :church_site,
    adapter: Ecto.Adapters.Postgres
end
