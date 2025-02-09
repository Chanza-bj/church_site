defmodule ChurchSiteWeb.UserAuth do
  import Plug.Conn

  def fetch_current_user(conn, _opts) do
    assign(conn, :current_user, nil)
  end
end
