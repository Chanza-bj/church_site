defmodule ChurchSiteWeb.Admin.SessionController do
  use ChurchSiteWeb, :controller

  alias ChurchSite.Accounts

  def new(conn, _params) do
    render(conn, :new,
      church_name: "Evelyn Hone",
      phone_number: "123-456-7890",
      email: "contact@church.com",
      address: "123 Church Street",
      website: "www.yourchurch.com"
    )
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Accounts.authenticate_admin(email, password) do
      {:ok, admin} ->
        conn
        |> put_session(:admin_id, admin.id)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: ~p"/777/dashboard")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> render(:new,
          church_name: "Evelyn Hone",
          phone_number: "123-456-7890",
          email: "contact@church.com",
          address: "123 Church Street",
          website: "www.yourchurch.com"
        )
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:admin_id)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: ~p"/777/login")
  end
end
