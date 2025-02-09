defmodule ChurchSite.Media.Media do
  use Ecto.Schema
  import Ecto.Changeset

  schema "media" do
    field :title, :string
    field :file_path, :string
    field :file_type, Ecto.Enum, values: [:image, :video, :audio, :document]
    field :file_size, :integer
    field :metadata, :map

    timestamps()
  end

  def changeset(media, attrs) do
    media
    |> cast(attrs, [:title, :file_path, :file_type, :file_size, :metadata])
    |> validate_required([:title, :file_path, :file_type, :file_size])
  end
end
