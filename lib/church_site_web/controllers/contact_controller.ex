defmodule ChurchSiteWeb.ContactController do
  use ChurchSiteWeb, :controller

  def index(conn, _params) do
    church_name = Application.get_env(:church_site, :church_name, "Default Church")
    render(conn, :index, church_name: church_name)
  end
end

defmodule ChurchSiteWeb.ContactHTML do
  use ChurchSiteWeb, :html

  embed_templates "contact_html/*"
end
