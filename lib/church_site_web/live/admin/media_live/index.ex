defmodule ChurchSiteWeb.Admin.MediaLive.Index do
  use ChurchSiteWeb, :live_view
  alias ChurchSite.Media
  alias ChurchSite.Media.MediaItem
  alias ChurchSite.Content.ImageProcessor

  @upload_options [
    accept: ~w(.jpg .jpeg .png),
    max_entries: 5,
    max_file_size: 10_000_000 # 10MB
  ]

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Media.subscribe()
    end

    {:ok,
     socket
     |> assign(:media_items, list_media())
     |> assign(:editing_item, nil)
     |> assign(:uploading, false)
     |> allow_upload(:media, @upload_options)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Media Gallery")
    |> assign(:media_item, nil)
  end

  @impl true
  def handle_event("save", %{"media_item" => media_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :media, fn %{path: path}, entry ->
        case ImageProcessor.process_image(path) do
          {:ok, %{main_path: main_path, thumb_path: thumb_path, metadata: metadata}} ->
            filename = "#{entry.uuid}#{Path.extname(path)}"
            thumb_filename = "thumb_#{filename}"

            dest = Path.join("priv/static/uploads", filename)
            thumb_dest = Path.join("priv/static/uploads", thumb_filename)

            File.cp!(main_path, dest)
            File.cp!(thumb_path, thumb_dest)

            # Cleanup temporary files
            ImageProcessor.cleanup_temp_files([main_path, thumb_path])

            url = Routes.static_path(socket, "/uploads/#{filename}")
            thumb_url = Routes.static_path(socket, "/uploads/#{thumb_filename}")

            {:ok, %{url: url, thumb_url: thumb_url, metadata: metadata}}

          {:error, reason} ->
            {:error, reason}
        end
      end)

    case uploaded_files do
      [%{url: url, thumb_url: thumb_url, metadata: metadata} | _] ->
        media_params = media_params
          |> Map.put("url", url)
          |> Map.put("thumbnail_url", thumb_url)
          |> Map.put("metadata", metadata)

        case Media.create_media_item(media_params) do
          {:ok, _media_item} ->
            {:noreply,
             socket
             |> put_flash(:info, "Media item created successfully")
             |> assign(:media_items, list_media())
             |> assign(:uploading, false)}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, changeset: changeset)}
        end

      [] ->
        {:noreply, put_flash(socket, :error, "No file uploaded")}
    end
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    media_item = Media.get_media_item!(id)
    {:noreply, assign(socket, :editing_item, media_item)}
  end

  def handle_event("cancel-edit", _, socket) do
    {:noreply, assign(socket, :editing_item, nil)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    media_item = Media.get_media_item!(id)

    # Delete the file
    media_item.url
    |> String.replace(Routes.static_path(socket, "/"), "priv/static/")
    |> File.rm()

    {:ok, _} = Media.delete_media_item(media_item)

    {:noreply,
     socket
     |> put_flash(:info, "Media item deleted successfully")
     |> assign(:media_items, list_media())}
  end

  defp list_media do
    Media.list_media_items()
  end
end
