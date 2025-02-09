defmodule ChurchSiteWeb.Admin.AnnouncementController do
  use ChurchSiteWeb, :controller

  alias ChurchSite.Content
  alias ChurchSite.Content.Announcement

  def index(conn, _params) do
    announcements = Content.list_announcements()
    render(conn, :index, announcements: announcements, layout: false)
  end

  def new(conn, _params) do
    changeset = Content.change_announcement(%Announcement{})
    render(conn, :new, changeset: changeset, action: ~p"/777/announcements", layout: false)
  end

  def create(conn, %{"announcement" => announcement_params}) do
    IO.inspect(announcement_params, label: "Announcement Params")  # Debug line

    case Content.create_announcement(announcement_params) do
      {:ok, _announcement} ->
        conn
        |> put_flash(:info, "Announcement created successfully.")
        |> redirect(to: ~p"/777/announcements")

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset, label: "Error Changeset")  # Debug line
        render(conn, :new, changeset: changeset, action: ~p"/777/announcements", layout: false)
    end
  end

  def edit(conn, %{"id" => id}) do
    announcement = Content.get_announcement!(id)
    changeset = Content.change_announcement(announcement)
    render(conn, :edit, announcement: announcement, changeset: changeset,
           action: ~p"/777/announcements/#{announcement.id}", layout: false)
  end

  def update(conn, %{"id" => id, "announcement" => announcement_params}) do
    announcement = Content.get_announcement!(id)

    case Content.update_announcement(announcement, announcement_params) do
      {:ok, _announcement} ->
        conn
        |> put_flash(:info, "Announcement updated successfully.")
        |> redirect(to: ~p"/777/announcements")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, announcement: announcement, changeset: changeset,
               action: ~p"/777/announcements/#{announcement.id}", layout: false)
    end
  end

  def delete(conn, %{"id" => id}) do
    announcement = Content.get_announcement!(id)
    {:ok, _announcement} = Content.delete_announcement(announcement)

    conn
    |> put_flash(:info, "Announcement deleted successfully.")
    |> redirect(to: ~p"/777/announcements")
  end

  def show(conn, %{"id" => id}) do
    announcement = Content.get_announcement!(id)
    render(conn, :show,
      announcement: announcement,
      church_name: "Evelyn Hone",
      layout: false
    )
  end
end
