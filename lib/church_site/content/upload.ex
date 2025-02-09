defmodule ChurchSite.Content.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uploads" do
    field :filename, :string
    field :content_type, :string
    field :path, :string
    field :size, :integer
    field :uploaded_by, :string

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:filename, :content_type, :path, :size, :uploaded_by])
    |> validate_required([:filename, :content_type, :path, :size])
  end
end
