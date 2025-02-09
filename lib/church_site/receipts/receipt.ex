defmodule ChurchSite.Receipts.Receipt do
  use Ecto.Schema
  import Ecto.Changeset

  schema "receipts" do
    field :receipt_number, :string
    field :amount, :decimal
    field :currency, :string
    field :payment_method, :string
    field :payment_status, :string
    field :payment_date, :utc_datetime
    field :payer_name, :string
    field :payer_phone, :string
    field :giving_type, :string
    field :payment_reference, :string

    timestamps()
  end

  @doc false
  def changeset(receipt, attrs) do
    receipt
    |> cast(attrs, [
      :receipt_number,
      :amount,
      :currency,
      :payment_method,
      :payment_status,
      :payment_date,
      :payer_name,
      :payer_phone,
      :giving_type,
      :payment_reference
    ])
    |> validate_required([
      :amount,
      :currency,
      :payment_method,
      :payment_status,
      :payment_date,
      :payer_name,
      :payer_phone,
      :giving_type,
      :payment_reference
    ])
    |> generate_receipt_number()
  end

  defp generate_receipt_number(changeset) do
    if get_field(changeset, :receipt_number) do
      changeset
    else
      date = DateTime.utc_now()
      random = :crypto.strong_rand_bytes(3) |> Base.encode16()
      receipt_number = "RCP#{date.year}#{pad(date.month)}#{pad(date.day)}#{random}"
      put_change(changeset, :receipt_number, receipt_number)
    end
  end

  defp pad(number), do: String.pad_leading("#{number}", 2, "0")
end

defmodule ChurchSite.Receipts do
  import Ecto.Query
  alias ChurchSite.Repo
  alias ChurchSite.Receipts.Receipt

  @doc """
  Gets a receipt by its receipt number.
  """
  def get_receipt(receipt_number) do
    Repo.get_by(Receipt, receipt_number: receipt_number)
  end

  @doc """
  Gets a receipt by payment reference.
  """
  def get_receipt_by_payment_reference(payment_reference) do
    Repo.get_by(Receipt, payment_reference: payment_reference)
  end

  @doc """
  Creates a receipt from a payment.
  """
  def create_receipt_from_payment(payment) do
    case get_receipt_by_payment_reference(payment.reference_id) do
      nil ->
        attrs = %{
          amount: payment.amount,
          currency: "ZMW",
          payer_name: payment.payer_name,
          payer_phone: payment.phone_number,
          giving_type: payment.giving_type,
          payment_method: payment.method,
          payment_reference: payment.reference_id,
          payment_status: payment.status,
          payment_date: payment.updated_at || DateTime.utc_now()
        }

        %Receipt{}
        |> Receipt.changeset(attrs)
        |> Repo.insert()

      existing_receipt ->
        {:ok, existing_receipt}
    end
  end

  @doc """
  Lists receipts with an optional limit.
  """
  def list_receipts(limit \\ 10) do
    Receipt
    |> limit(^limit)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Searches receipts by receipt number, payer name, or payment reference.
  """
  def search_receipts(search_term) do
    search = "%#{search_term}%"

    Receipt
    |> where([r], ilike(r.receipt_number, ^search)
             or ilike(r.payer_name, ^search)
             or ilike(r.payment_reference, ^search))
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Generates a unique receipt number.
  """
  def generate_receipt_number do
    prefix = "RCP"
    date = Date.utc_today() |> Date.to_string() |> String.replace("-", "")
    random = :crypto.strong_rand_bytes(3) |> Base.encode16()
    "#{prefix}#{date}#{random}"
  end
end
