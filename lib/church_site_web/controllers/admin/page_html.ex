defmodule ChurchSiteWeb.Admin.PageHTML do
  use ChurchSiteWeb, :html

  embed_templates "page_html/*.heex"
  embed_templates "page_html/shared/*.heex"

  def status_badge_class(status) do
    base_classes = "px-2 py-1 text-xs font-medium rounded-full"

    case status do
      "published" -> "#{base_classes} bg-green-100 text-green-800"
      "draft" -> "#{base_classes} bg-yellow-100 text-yellow-800"
    end
  end
end
