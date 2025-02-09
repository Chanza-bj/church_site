defmodule ChurchSite.Receipt do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias ChurchSite.Repo

  schema "receipts" do
    field :receipt_number, :string
    field :amount, :decimal
    field :currency, :string
    field :payment_method, :string
    field :payer_name, :string
    field :payer_phone, :string
    field :giving_type, :string
    field :payment_reference, :string
    field :payment_status, :string
    field :payment_date, :utc_datetime

    timestamps()
  end

  def changeset(receipt, attrs) do
    receipt
    |> cast(attrs, [:receipt_number, :amount, :currency, :payment_method,
                    :payer_name, :payer_phone, :giving_type,
                    :payment_reference, :payment_status, :payment_date])
    |> validate_required([:receipt_number, :amount, :payment_method,
                         :payer_name, :giving_type, :payment_reference])
    |> unique_constraint(:receipt_number)
  end

  def generate_receipt_number do
    prefix = "RCP"
    date = Date.utc_today() |> Date.to_string() |> String.replace("-", "")
    sequence = :rand.uniform(9999) |> Integer.to_string() |> String.pad_leading(4, "0")
    "#{prefix}#{date}#{sequence}"
  end

  def create_receipt(attrs) do
    %__MODULE__{}
    |> changeset(Map.put(attrs, :receipt_number, generate_receipt_number()))
    |> Repo.insert()
  end

  def get_receipt(receipt_number) do
    Repo.get_by(__MODULE__, receipt_number: receipt_number)
  end

  def get_receipts_by_phone(phone_number) do
    from(r in __MODULE__,
      where: r.payer_phone == ^phone_number,
      order_by: [desc: r.payment_date]
    )
    |> Repo.all()
  end
end
