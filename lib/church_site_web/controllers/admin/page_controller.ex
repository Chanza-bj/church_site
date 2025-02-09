defmodule ChurchSiteWeb.Admin.PageController do
  use ChurchSiteWeb, :controller

  alias ChurchSite.Content.Page
  alias ChurchSite.Repo
  import Ecto.Query

  plug :put_layout, html: {ChurchSiteWeb.Layouts, :admin}

  def index(conn, _params) do
    pages = Repo.all(from p in Page, order_by: p.title)
    render(conn, :index, pages: pages)
  end

  def new(conn, _params) do
    changeset = Page.changeset(%Page{}, %{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"page" => page_params}) do
    case Repo.insert(Page.changeset(%Page{}, page_params)) do
      {:ok, page} ->
        conn
        |> put_flash(:info, "Page created successfully.")
        |> redirect(to: ~p"/777/pages/#{page}")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    page = Repo.get!(Page, id)
    changeset = Page.changeset(page, %{})
    render(conn, :edit, page: page, changeset: changeset)
  end

  def update(conn, %{"id" => id, "page" => page_params}) do
    page = Repo.get!(Page, id)

    case Repo.update(Page.changeset(page, page_params)) do
      {:ok, page} ->
        conn
        |> put_flash(:info, "Page updated successfully.")
        |> redirect(to: ~p"/777/pages/#{page}")

      {:error, changeset} ->
        render(conn, :edit, page: page, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    page = Repo.get!(Page, id)
    {:ok, _page} = Repo.delete(page)

    conn
    |> put_flash(:info, "Page deleted successfully.")
    |> redirect(to: ~p"/777/pages")
  end

  def show(conn, %{"id" => id}) do
    page = Repo.get!(Page, id)
    render(conn, :show, page: page)
  end
end
