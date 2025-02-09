defmodule ChurchSite.Repo.Migrations.CreateReceipts do
  use Ecto.Migration

  def change do
    create table(:receipts) do
      add :receipt_number, :string, null: false
      add :amount, :decimal, precision: 10, scale: 2, null: false
      add :currency, :string, null: false
      add :payer_name, :string, null: false
      add :payer_phone, :string
      add :giving_type, :string, null: false  # tithe, offering, etc.
      add :payment_method, :string, null: false  # cash, mobile_money, bank_transfer
      add :payment_reference, :string
      add :payment_status, :string, default: "pending"  # pending, completed, failed
      add :payment_date, :utc_datetime

      timestamps()
    end

    create unique_index(:receipts, [:receipt_number])
    create index(:receipts, [:payment_status])
    create index(:receipts, [:giving_type])
  end
end
