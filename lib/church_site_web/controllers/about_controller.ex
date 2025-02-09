defmodule ChurchSiteWeb.AboutController do
  use ChurchSiteWeb, :controller

  def index(conn, _params) do
    church_name = Application.get_env(:church_site, :church_name)
    render(conn, :index, church_name: church_name)
  end

  def about_us(conn, _params) do
    church_name = Application.get_env(:church_site, :church_name)
    render(conn, :about_us, church_name: church_name)
  end

  def what_to_expect(conn, _params) do
    render(conn, :what_to_expect)
  end

  def beliefs(conn, _params) do
    render(conn, :beliefs)
  end

  def pastor(conn, _params) do
    render(conn, :pastor)
  end

  def logo(conn, _params) do
    render(conn, :logo)
  end
end
