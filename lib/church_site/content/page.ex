defmodule ChurchSite.Content.Page do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "pages" do
    field :title, :string
    field :slug, :string
    field :content, :string
    field :status, :string, default: "draft"
    field :meta_description, :string
    field :meta_keywords, :string

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:title, :slug, :content, :status, :meta_description, :meta_keywords])
    |> validate_required([:title, :content])
    |> validate_inclusion(:status, ["draft", "published"])
    |> generate_slug()
    |> unique_constraint(:slug)
  end

  defp generate_slug(changeset) do
    case get_change(changeset, :title) do
      nil -> changeset
      title ->
        slug = title
        |> String.downcase()
        |> String.replace(~r/[^a-z0-9\s-]/, "")
        |> String.replace(~r/\s+/, "-")
        put_change(changeset, :slug, slug)
    end
  end

  def published(query \\ __MODULE__) do
    query
    |> where([p], p.status == "published")
    |> order_by([p], [asc: p.title])
  end
end
