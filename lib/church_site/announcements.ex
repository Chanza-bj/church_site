defmodule ChurchSite.Announcements do
  import Ecto.Query
  alias ChurchSite.Repo
  alias ChurchSite.Announcements.Announcement

  def list_announcements do
    Repo.all(Announcement)
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
    |> Repo.update()
  end

  def delete_announcement(%Announcement{} = announcement) do
    Repo.delete(announcement)
  end

  def change_announcement(%Announcement{} = announcement, attrs \\ %{}) do
    Announcement.changeset(announcement, attrs)
  end
end
