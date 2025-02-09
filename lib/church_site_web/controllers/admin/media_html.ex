defmodule ChurchSiteWeb.Admin.MediaHTML do
  use ChurchSiteWeb, :html
  import Phoenix.HTML.Form

  embed_templates "media_html/*"

  @doc """
  Renders a media form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def format_size(bytes) when is_integer(bytes) do
    cond do
      bytes >= 1_000_000 -> "#{Float.round(bytes / 1_000_000, 2)} MB"
      bytes >= 1_000 -> "#{Float.round(bytes / 1_000, 2)} KB"
      true -> "#{bytes} bytes"
    end
  end

  def is_image?(content_type) do
    String.starts_with?(content_type, "image/")
  end

  def index(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Media Library</h1>
        <.link href={~p"/777/media/new"} class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
          Add Media
        </.link>
      </div>

      <div class="bg-white shadow overflow-hidden sm:rounded-lg">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <%= for media <- @media_items do %>
              <tr>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%= media.title %></td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= media.type %></td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class={status_badge_class(media.status)}><%= media.status %></span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <.link href={~p"/777/media/#{media.id}/edit"} class="text-indigo-600 hover:text-indigo-900">Edit</.link>
                  <.link href={~p"/777/media/#{media.id}"} method="delete" data-confirm="Are you sure?" class="ml-4 text-red-600 hover:text-red-900">Delete</.link>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp status_badge_class(status) do
    case status do
      "published" -> "bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs font-medium"
      "draft" -> "bg-yellow-100 text-yellow-800 px-2 py-1 rounded-full text-xs font-medium"
      _ -> "bg-gray-100 text-gray-800 px-2 py-1 rounded-full text-xs font-medium"
    end
  end

  def media_form(assigns)
end
