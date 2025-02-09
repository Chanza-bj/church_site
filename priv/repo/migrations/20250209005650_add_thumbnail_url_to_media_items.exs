defmodule ChurchSite.Repo.Migrations.AddMissingColumnsToMediaItems do
  use Ecto.Migration

  def change do
    alter table(:media_items) do
      add_if_not_exists :thumbnail_url, :string
      add_if_not_exists :section, :string
      add_if_not_exists :display_order, :integer
      add_if_not_exists :alt_text, :string
    end
  end
end
