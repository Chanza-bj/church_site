defmodule ChurchSite.Repo.Migrations.CreateAnnouncements do
  use Ecto.Migration

  def change do
    create table(:announcements) do
      add :title, :string, null: false
      add :content, :text
      add :status, :string, default: "draft"
      add :published_at, :utc_datetime
      add :expires_at, :utc_datetime
      add :priority, :integer, default: 0

      timestamps()
    end

    create index(:announcements, [:status])
    create index(:announcements, [:priority])
  end
end

defmodule ChurchSite.Repo.Migrations.CreateMediaItems do
  use Ecto.Migration

  def change do
    create table(:media_items) do
      add :title, :string, null: false
      add :description, :text
      add :type, :string, null: false
      add :url, :string, null: false
      add :status, :string, default: "draft"
      add :published_at, :utc_datetime

      timestamps()
    end

    create index(:media_items, [:type])
    create index(:media_items, [:status])
  end
end
