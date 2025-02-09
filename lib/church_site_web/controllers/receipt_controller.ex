defmodule ChurchSiteWeb.ReceiptController do
  use ChurchSiteWeb, :controller

  alias ChurchSite.Receipts

  def show(conn, %{"receipt_number" => receipt_number}) do
    case Receipts.get_receipt(receipt_number) do
      nil ->
        conn
        |> put_flash(:error, "Receipt not found")
        |> redirect(to: ~p"/")

      receipt ->
        render(conn, :show,
          receipt: receipt,
          page_title: "Receipt #{receipt.receipt_number}",
          church_name: "Evelyn Hone SDA Church",
          church_address: "Church Road, Lusaka"
        )
    end
  end
end
