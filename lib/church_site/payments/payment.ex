defmodule ChurchSite.Payments.Payment do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChurchSite.Repo

  schema "payments" do
    field :reference_id, :string
    field :amount, :decimal
    field :giving_type, :string
    field :method, :string
    field :payer_name, :string
    field :phone_number, :string
    field :status, :string, default: "pending"

    timestamps()
  end

  @payment_methods ["MTN", "AIRTEL", "ZAMTEL"]
  @giving_types ["tithe", "church_offering", "special_offering", "youth_ministry", "building_fund", "missions", "mission_projects"]
  @payment_statuses ["pending", "completed", "failed"]

  @required_fields [:reference_id, :amount, :giving_type, :method, :payer_name, :phone_number]
  @optional_fields [:status]

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:amount, :payer_name, :giving_type, :phone_number, :method, :reference_id, :status])
    |> validate_required([:amount, :payer_name, :giving_type, :phone_number, :method, :reference_id])
    |> validate_inclusion(:status, @payment_statuses)
    |> validate_inclusion(:method, @payment_methods)
    |> validate_inclusion(:giving_type, @giving_types)
    |> validate_number(:amount, greater_than: 0)
    |> unique_constraint(:reference_id)
    |> update_change(:giving_type, &String.downcase/1)
    |> update_change(:method, &String.upcase/1)
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def update_status(reference_id, status) do
    case Repo.get_by(__MODULE__, reference_id: reference_id) do
      nil -> {:error, :not_found}
      payment ->
        payment
        |> changeset(%{status: status})
        |> Repo.update()
    end
  end
end
