defmodule ChurchSiteWeb.Admin.ReceiptController do
  use ChurchSiteWeb, :controller

  alias ChurchSite.Receipts.Receipt
  alias ChurchSite.Repo
  import Ecto.Query

  @items_per_page 7  # You can adjust this number

  plug :put_layout, html: {ChurchSiteWeb.Layouts, :admin}

  def index(conn, params) do
    page_number = String.to_integer(params["page"] || "1")

    # Get total count for pagination
    total_count = Receipt |> Repo.aggregate(:count, :id)
    total_pages = ceil(total_count / @items_per_page)

    # Fetch paginated receipts
    receipts = Receipt
    |> order_by(desc: :inserted_at)
    |> limit(@items_per_page)
    |> offset(^((page_number - 1) * @items_per_page))
    |> Repo.all()

    render(conn, :index,
      receipts: receipts,
      page_number: page_number,
      total_pages: total_pages
    )
  end

  def show(conn, %{"id" => id}) do
    receipt = Repo.get!(Receipt, id)
    render(conn, :show, receipt: receipt)
  end

  def export_csv(conn, _params) do
    receipts = Receipt
    |> order_by(desc: :inserted_at)
    |> Repo.all()

    csv_content = generate_csv(receipts)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=receipts.csv")
    |> send_resp(200, csv_content)
  end

  defp generate_csv(receipts) do
    headers = [
      "Receipt Number",
      "Date",
      "Amount",
      "Currency",
      "Payer Name",
      "Phone",
      "Giving Type",
      "Payment Method",
      "Status"
    ]

    rows = Enum.map(receipts, fn receipt ->
      [
        receipt.receipt_number,
        Calendar.strftime(receipt.payment_date, "%Y-%m-%d %H:%M:%S"),
        receipt.amount,
        receipt.currency,
        receipt.payer_name,
        receipt.payer_phone,
        receipt.giving_type,
        receipt.payment_method,
        receipt.payment_status
      ]
    end)

    ([headers] ++ rows)
    |> CSV.encode()
    |> Enum.to_list()
    |> Enum.join()
  end
end
