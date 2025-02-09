defmodule ChurchSiteWeb.Admin.AnnouncementHTML do
  use ChurchSiteWeb, :html
  import Phoenix.HTML.Form
  import Phoenix.HTML.Link

  def status_badge_class(status) do
    case status do
      "published" -> "bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs font-medium"
      "draft" -> "bg-yellow-100 text-yellow-800 px-2 py-1 rounded-full text-xs font-medium"
      _ -> "bg-gray-100 text-gray-800 px-2 py-1 rounded-full text-xs font-medium"
    end
  end

  def form_component(assigns) do
    ~H"""
    <form action={@action} method="post" class="space-y-6">
      <input type="hidden" name="_csrf_token" value={get_csrf_token()} />
      <%= if @changeset.data.id do %>
        <input type="hidden" name="_method" value="put" />
      <% end %>

      <div>
        <label class="block text-sm font-medium text-gray-700">Title</label>
        <input type="text" name="announcement[title]" value={@changeset.changes[:title] || @changeset.data.title}
               class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700">Content</label>
        <textarea name="announcement[content]" rows="4"
                  class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500">
          <%= @changeset.changes[:content] || @changeset.data.content %>
        </textarea>
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700">Status</label>
        <select name="announcement[status]" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500">
          <option value="draft" selected={(@changeset.changes[:status] || @changeset.data.status) == "draft"}>Draft</option>
          <option value="published" selected={(@changeset.changes[:status] || @changeset.data.status) == "published"}>Published</option>
        </select>
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700">Priority</label>
        <input type="number" name="announcement[priority]" value={@changeset.changes[:priority] || @changeset.data.priority}
               class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700">Publish Date</label>
        <input type="datetime-local" name="announcement[published_at]"
               value={format_datetime(@changeset.changes[:published_at] || @changeset.data.published_at)}
               class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700">Expiry Date</label>
        <input type="datetime-local" name="announcement[expires_at]"
               value={format_datetime(@changeset.changes[:expires_at] || @changeset.data.expires_at)}
               class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" />
      </div>

      <div class="mt-6 flex justify-end gap-3">
        <a href={~p"/777/announcements"} class="rounded-lg bg-gray-100 px-4 py-2 text-gray-600 hover:bg-gray-200">
          Cancel
        </a>
        <button type="submit" class="rounded-lg bg-indigo-600 px-4 py-2 text-white hover:bg-indigo-700">
          Save
        </button>
      </div>
    </form>
    """
  end

  defp format_datetime(nil), do: nil
  defp format_datetime(datetime) when is_binary(datetime), do: datetime
  defp format_datetime(datetime) do
    datetime
    |> DateTime.to_naive()
    |> NaiveDateTime.to_iso8601()
    |> String.replace(~r/:\d{2}$/, "")
  end

  def index(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Announcements</h1>
        <.link href={~p"/777/announcements/new"} class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
          New Announcement
        </.link>
      </div>

      <div class="bg-white shadow overflow-hidden sm:rounded-lg">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Published At</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <%= for announcement <- @announcements do %>
              <tr>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%= announcement.title %></td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class={status_badge_class(announcement.status)}><%= announcement.status %></span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <%= if announcement.published_at, do: Calendar.strftime(announcement.published_at, "%Y-%m-%d %H:%M") %>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <.link href={~p"/777/announcements/#{announcement.id}/edit"} class="text-indigo-600 hover:text-indigo-900">Edit</.link>
                  <.link href={~p"/777/announcements/#{announcement.id}"} method="delete" data-confirm="Are you sure?" class="ml-4 text-red-600 hover:text-red-900">Delete</.link>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  def new(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl">
      <h1 class="text-2xl font-bold mb-6">New -Announcement</h1>
      <.form_component changeset={@changeset} action={@action} />
    </div>
    """
  end

  def edit(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl">
      <h1 class="text-2xl font-bold mb-6">Edit Announcement</h1>
      <.form_component changeset={@changeset} action={@action} />
    </div>
    """
  end

  def show(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl">
      <div class="bg-white shadow overflow-hidden sm:rounded-lg">
        <div class="px-4 py-5 sm:px-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900"><%= @announcement.title %></h3>
          <p class="mt-1 max-w-2xl text-sm text-gray-500">
            <span class={status_badge_class(@announcement.status)}><%= @announcement.status %></span>
          </p>
        </div>
        <div class="border-t border-gray-200 px-4 py-5 sm:px-6">
          <div class="prose max-w-none">
            <%= @announcement.content %>
          </div>
        </div>
        <div class="border-t border-gray-200 px-4 py-5 sm:px-6">
          <div class="flex justify-end space-x-4">
            <.link href={~p"/777/announcements"} class="text-gray-600 hover:text-gray-900">Back to list</.link>
            <.link href={~p"/777/announcements/#{@announcement.id}/edit"} class="text-indigo-600 hover:text-indigo-900">Edit</.link>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
