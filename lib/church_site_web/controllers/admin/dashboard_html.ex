defmodule ChurchSiteWeb.Admin.DashboardHTML do
  use ChurchSiteWeb, :html

  embed_templates "dashboard_html/*"

  def index(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Admin Dashboard</h1>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div class="bg-white p-4 rounded shadow">
          <h2 class="font-bold mb-2">Quick Links</h2>
          <ul class="space-y-2">
            <li><.link href={~p"/777/announcements"}>Announcements</.link></li>
            <li><.link href={~p"/777/payments"}>Payments</.link></li>
            <li><.link href={~p"/777/receipts"}>Receipts</.link></li>
          </ul>
        </div>
      </div>
    </div>
    """
  end
end
