defmodule ChurchSite.Content.Announcement do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "announcements" do
    field :title, :string
    field :content, :string
    field :status, :string, default: "draft"
    field :priority, :integer, default: 0
    field :published_at, :utc_datetime
    field :expires_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(announcement, attrs) do
    announcement
    |> cast(attrs, [:title, :content, :status, :priority, :published_at, :expires_at])
    |> validate_required([:title, :content, :status])
    |> validate_inclusion(:status, ["draft", "published"])
    |> validate_dates()
  end

  defp validate_dates(changeset) do
    changeset
    |> validate_datetime(:published_at)
    |> validate_datetime(:expires_at)
    |> validate_expiry_after_publish()
  end

  defp validate_datetime(changeset, field) do
    case get_change(changeset, field) do
      nil -> changeset
      datetime when is_binary(datetime) ->
        case DateTime.from_iso8601(datetime) do
          {:ok, datetime_utc, _} ->
            put_change(changeset, field, datetime_utc)
          {:error, _} ->
            add_error(changeset, field, "is invalid")
        end
      _datetime -> changeset
    end
  end

  defp validate_expiry_after_publish(changeset) do
    published_at = get_field(changeset, :published_at)
    expires_at = get_field(changeset, :expires_at)

    case {published_at, expires_at} do
      {published, expired} when not is_nil(published) and not is_nil(expired) ->
        if DateTime.compare(expired, published) == :gt do
          changeset
        else
          add_error(changeset, :expires_at, "must be after published date")
        end
      _ -> changeset
    end
  end

  def published(query \\ __MODULE__) do
    now = DateTime.utc_now()

    query
    |> where([a], a.status == "published")
    |> where([a], a.published_at <= ^now)
    |> where([a], is_nil(a.expires_at) or a.expires_at > ^now)
    |> order_by([a], [desc: a.priority, desc: a.published_at])
  end
end
