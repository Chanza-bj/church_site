defmodule ChurchSite.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :status, :string, null: false
      add :method, :string, null: false
      add :amount, :decimal, precision: 10, scale: 2, null: false
      add :payer_name, :string, null: false
      add :giving_type, :string, null: false
      add :phone_number, :string
      add :reference_id, :string, null: false

      timestamps()
    end

    create unique_index(:payments, [:reference_id])
    create index(:payments, [:status])
    create index(:payments, [:giving_type])
  end
end
