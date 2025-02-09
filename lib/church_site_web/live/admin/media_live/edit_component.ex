defmodule ChurchSiteWeb.Admin.MediaLive.EditComponent do
  use ChurchSiteWeb, :live_component
  alias ChurchSite.Media

  @impl true
  def update(%{media_item: media_item} = assigns, socket) do
    changeset = Media.change_media_item(media_item)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"media_item" => media_item_params}, socket) do
    case Media.update_media_item(socket.assigns.media_item, media_item_params) do
      {:ok, _media_item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Media item updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
