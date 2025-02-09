defmodule ChurchSite.Repo.Migrations.AddThumbnailUrlToMediaItems do
  use Ecto.Migration

  def change do
    alter table(:media_items) do
      add :thumbnail_url, :string
    end
  end
end
