defmodule ChurchSite.Media do
  @moduledoc """
  The Media context.
  """

  import Ecto.Query, warn: false
  alias ChurchSite.Repo
  alias ChurchSite.Media.MediaItem

  @doc """
  Returns the list of media_items.
  """
  def list_media_items do
    Repo.all(MediaItem)
  end

  @doc """
  Gets a single media_item.

  Raises `Ecto.NoResultsError` if the Media item does not exist.
  """
  def get_media_item!(id) do
    Repo.get!(MediaItem, id)
  end

  @doc """
  Creates a media_item.
  """
  def create_media_item(attrs \\ %{}) do
    %MediaItem{}
    |> MediaItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a media_item.
  """
  def update_media(media, attrs) do
    media
    |> MediaItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a media_item.
  """
  def delete_media(media) do
    Repo.delete(media)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking media_item changes.
  """
  def change_media(%MediaItem{} = media, attrs \\ %{}) do
    MediaItem.changeset(media, attrs)
  end

  @doc """
  Gets all active slider images in display order.
  """
  def list_slider_images do
    from(m in MediaItem,
      where: m.type == "slider" and m.status == "active",
      order_by: [asc: m.display_order]
    )
    |> Repo.all()
  end

  @doc """
  Gets specific section image (welcome, pastor signature, etc.).
  """
  def get_section_image(section) do
    from(m in MediaItem,
      where: m.section == ^section and m.status == "active",
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Gets all active feature section images.
  """
  def list_feature_images do
    from(m in MediaItem,
      where: m.type == "feature" and m.status == "active",
      order_by: [asc: m.display_order]
    )
    |> Repo.all()
  end

  @doc """
  Gets all active about section images.
  """
  def list_about_images do
    from(m in MediaItem,
      where: m.type == "about" and m.status == "active",
      order_by: [asc: m.display_order]
    )
    |> Repo.all()
  end

  @doc """
  Gets all active images for a specific type.
  """
  def list_images_by_type(type) do
    from(m in MediaItem,
      where: m.type == ^type and m.status == "active",
      order_by: [asc: m.display_order]
    )
    |> Repo.all()
  end

  def list_media_items_by_type(type) do
    from(m in MediaItem,
      where: m.type == ^type and m.status == "active",
      order_by: [asc: :display_order]
    )
    |> Repo.all()
  end

  @doc """
  Gets a media item by section.
  """
  def get_media_item_by_section(section) do
    Repo.get_by(MediaItem, section: section, status: "active")
  end

  def delete_media_item(%MediaItem{} = media_item) do
    # Delete the file from uploads directory if it exists
    if media_item.url do
      file_path = Path.join("priv/static", media_item.url)
      File.rm(file_path)
    end

    Repo.delete(media_item)
  end
end
