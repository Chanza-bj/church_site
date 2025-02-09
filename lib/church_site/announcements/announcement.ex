defmodule ChurchSite.Announcements.Announcement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "announcements" do
    field :title, :string
    field :content, :string
    field :published_at, :naive_datetime
    field :status, Ecto.Enum, values: [:draft, :published]

    timestamps()
  end

  def changeset(announcement, attrs) do
    announcement
    |> cast(attrs, [:title, :content, :published_at, :status])
    |> validate_required([:title, :content, :status])
  end
end
