defmodule ChurchSite.Media.MediaItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "media_items" do
    field :title, :string
    field :description, :string
    field :url, :string
    field :thumbnail_url, :string
    field :type, :string
    field :status, :string
    field :section, :string
    field :display_order, :integer
    field :alt_text, :string

    timestamps()
  end

  @doc false
  def changeset(media_item, attrs) do
    media_item
    |> cast(attrs, [:title, :description, :url, :thumbnail_url, :type, :status, :section, :display_order, :alt_text])
    |> validate_required([:title, :url, :type, :status])
  end
end
