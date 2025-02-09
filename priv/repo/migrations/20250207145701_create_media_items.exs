defmodule ChurchSite.Repo.Migrations.CreateMediaItems do
  use Ecto.Migration

  def change do
    create table(:media_items) do
      add :title, :string
      add :description, :text
      add :type, :string  # For "slider", "gallery", etc.
      add :url, :string
      add :thumbnail_url, :string
      add :status, :string, default: "active"
      add :published_at, :utc_datetime
      add :section, :string  # For "welcome_image", "pastor_signature", etc.
      add :display_order, :integer
      add :alt_text, :string

      timestamps()
    end

    create index(:media_items, [:type])
    create index(:media_items, [:section])
    create index(:media_items, [:status])
  end
end
