defmodule ChurchSite.Accounts.Admin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "admins" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :name, :string
    field :role, :string, default: "admin"
    field :active, :boolean, default: true

    timestamps()
  end

  def changeset(admin, attrs) do
    admin
    |> cast(attrs, [:email, :password, :name, :role, :active])
    |> validate_required([:email, :password, :name])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_length(:password, min: 6)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset

  # Add convenience functions for admin creation and authentication
  def create_admin(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> ChurchSite.Repo.insert()
  end

  def authenticate_admin(email, password) do
    admin = ChurchSite.Repo.get_by(__MODULE__, email: email)

    cond do
      admin && Pbkdf2.verify_pass(password, admin.password_hash) ->
        {:ok, admin}
      admin ->
        {:error, :unauthorized}
      true ->
        # Prevent timing attacks by simulating password check
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end
end
