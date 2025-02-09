defmodule ChurchSite.Accounts do
  import Ecto.Query
  alias ChurchSite.Repo
  alias ChurchSite.Accounts.Admin

  def authenticate_admin(email, password) do
    admin = Repo.get_by(Admin, email: email)

    case admin do
      nil ->
        {:error, :not_found}
      admin ->
        if Pbkdf2.verify_pass(password, admin.password_hash) do
          {:ok, admin}
        else
          {:error, :invalid_password}
        end
    end
  end

  def get_admin!(id), do: Repo.get!(Admin, id)
  def get_admin_by_email(email), do: Repo.get_by(Admin, email: email)
end
