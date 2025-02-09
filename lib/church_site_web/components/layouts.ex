defmodule ChurchSiteWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use ChurchSiteWeb, :controller` and
  `use ChurchSiteWeb, :live_view`.
  """
  use ChurchSiteWeb, :html

  import ChurchSiteWeb.Components.StickyMenu

  embed_templates "layouts/*"

  def admin(assigns) do
    ~H"""
    <main class="container">
      <%= @inner_content %>
    </main>
    """
  end
end
