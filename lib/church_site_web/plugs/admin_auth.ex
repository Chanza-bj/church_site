defmodule ChurchSiteWeb.Plugs.AdminAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias ChurchSite.Accounts.Admin
  alias ChurchSite.Repo

  def init(opts), do: opts

  def call(conn, _opts) do
    if admin_id = get_session(conn, :admin_id) do
      case Repo.get(Admin, admin_id) do
        %Admin{} = admin ->
          assign(conn, :current_admin, admin)
        nil ->
          logout_admin(conn)
      end
    else
      logout_admin(conn)
    end
  end

  defp logout_admin(conn) do
    conn
    |> delete_session(:admin_id)
    |> put_flash(:error, "Please log in to access this page")
    |> redirect(to: "/777/login")
    |> halt()
  end
end
