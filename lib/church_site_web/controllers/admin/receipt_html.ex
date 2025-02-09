defmodule ChurchSiteWeb.Admin.ReceiptHTML do
  use ChurchSiteWeb, :html

  embed_templates "receipt_html/*"

  def status_badge_class(status) do
    base_classes = "px-2 py-1 text-xs font-medium rounded-full"

    case status do
      "SUCCESSFUL" -> "#{base_classes} bg-green-100 text-green-800"
      "FAILED" -> "#{base_classes} bg-red-100 text-red-800"
      _ -> "#{base_classes} bg-yellow-100 text-yellow-800"
    end
  end
end
