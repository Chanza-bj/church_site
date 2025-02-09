defmodule ChurchSite.Content do
  import Ecto.Query
  alias ChurchSite.Repo
  alias ChurchSite.Content.Announcement

  def list_announcements do
    Repo.all(Announcement)
  end

  def list_published_announcements do
    Announcement
    |> where([a], a.status == "published")
    |> order_by([a], desc: a.published_at)
    |> Repo.all()
  end

  def get_announcement!(id), do: Repo.get!(Announcement, id)

  def create_announcement(attrs \\ %{}) do
    %Announcement{}
    |> Announcement.changeset(attrs)
    |> Repo.insert()
  end

  def update_announcement(%Announcement{} = announcement, attrs) do
    announcement
    |> Announcement.changeset(attrs)
    |> IO.inspect(label: "Changeset before update")  # Debug line
    |> Repo.update()
  end

  def delete_announcement(%Announcement{} = announcement) do
    Repo.delete(announcement)
  end

  def change_announcement(%Announcement{} = announcement, attrs \\ %{}) do
    Announcement.changeset(announcement, attrs)
  end
end
