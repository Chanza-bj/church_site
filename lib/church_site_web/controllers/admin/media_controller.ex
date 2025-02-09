defmodule ChurchSiteWeb.Admin.MediaController do
  use ChurchSiteWeb, :controller

  alias ChurchSite.Media
  alias ChurchSite.Media.MediaItem

  def index(conn, _params) do
    media_items = Media.list_media_items()
    render(conn, :index,
      media_items: media_items,
      media_files: media_items,
      church_name: "Evelyn Hone"
    )
  end

  def new(conn, _params) do
    changeset = Media.change_media(%MediaItem{})
    render(conn, :new, changeset: changeset, church_name: "Evelyn Hone")
  end

  def create(conn, %{"media_item" => media_params}) do
    {file, params} = Map.pop(media_params, "file")

    case handle_upload(file, params) do
      {:ok, updated_params} ->
        case Media.create_media_item(updated_params) do
          {:ok, _media_item} ->
            conn
            |> put_flash(:info, "Media item created successfully.")
            |> redirect(to: ~p"/admin/media")

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, :new, changeset: changeset, church_name: "Evelyn Hone")
        end

      {:error, _reason} ->
        changeset = Media.change_media(%MediaItem{})
        conn
        |> put_flash(:error, "Error uploading file.")
        |> render(:new, changeset: changeset, church_name: "Evelyn Hone")
    end
  end

  defp handle_upload(%Plug.Upload{} = upload, params) do
    extension = Path.extname(upload.filename)
    file_uuid = Ecto.UUID.generate()
    file_name = "#{file_uuid}#{extension}"

    File.mkdir_p!("priv/static/uploads")

    dest = Path.join("priv/static/uploads", file_name)

    case File.cp(upload.path, dest) do
      :ok ->
        {:ok, Map.merge(params, %{
          "url" => "/uploads/#{file_name}",
          "thumbnail_url" => "/uploads/#{file_name}"
        })}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp handle_upload(nil, params), do: {:ok, params}

  def edit(conn, %{"id" => id}) do
    media_item = Media.get_media_item!(id)
    changeset = Media.change_media(media_item)
    render(conn, :edit, media_item: media_item, changeset: changeset, church_name: "Evelyn Hone")
  end

  def update(conn, %{"id" => id, "media_item" => media_params}) do
    media_item = Media.get_media_item!(id)

    case Media.update_media(media_item, media_params) do
      {:ok, _media_item} ->
        conn
        |> put_flash(:info, "Media item updated successfully.")
        |> redirect(to: ~p"/admin/media")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, media_item: media_item, changeset: changeset, church_name: "Evelyn Hone")
    end
  end

  def delete(conn, %{"id" => id}) do
    media_item = Media.get_media_item!(id)
    {:ok, _media_item} = Media.delete_media_item(media_item)

    conn
    |> put_flash(:info, "Media item deleted successfully.")
    |> redirect(to: ~p"/admin/media")
  end

  def show(conn, %{"id" => id}) do
    media_item = Media.get_media_item!(id)
    render(conn, :show, media_item: media_item, church_name: "Evelyn Hone")
  end
end
