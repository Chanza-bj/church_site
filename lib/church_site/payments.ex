defmodule ChurchSite.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false
  alias ChurchSite.Repo
  alias ChurchSite.Payments.Payment

  def list_payments do
    Repo.all(Payment)
  end

  def get_payment!(id), do: Repo.get!(Payment, id)

  @doc """
  Gets a payment by reference_id.
  """
  def get_payment_by_reference(reference_id) do
    Repo.get_by(Payment, reference_id: reference_id)
  end

  def create_payment(attrs \\ %{}) do
    %Payment{}
    |> Payment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a payment.
  """
  def update_payment(%Payment{} = payment, attrs) do
    IO.puts("Updating payment #{payment.id} with attrs: #{inspect(attrs)}")

    payment
    |> Payment.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, updated_payment} = result ->
        IO.puts("Payment updated successfully: #{inspect(updated_payment)}")
        result
      {:error, changeset} = error ->
        IO.puts("Payment update failed: #{inspect(changeset)}")
        error
    end
  end

  def delete_payment(%Payment{} = payment) do
    Repo.delete(payment)
  end

  def change_payment(%Payment{} = payment, attrs \\ %{}) do
    Payment.changeset(payment, attrs)
  end

  def list_payments_by_status(status) do
    Payment
    |> where([p], p.status == ^status)
    |> Repo.all()
  end
end
