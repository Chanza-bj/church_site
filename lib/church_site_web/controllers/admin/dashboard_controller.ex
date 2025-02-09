defmodule ChurchSiteWeb.Admin.DashboardController do
  use ChurchSiteWeb, :controller

  def index(conn, _params) do
    render(conn, :index, layout: false)
  end
end
