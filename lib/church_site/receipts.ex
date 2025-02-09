# # defmodule ChurchSite.Receipts do
#   import Ecto.Query
#   alias ChurchSite.Repo
#   alias ChurchSite.Receipts.Receipt

#   def create_receipt_from_payment(payment) do
#     attrs = %{
#       amount: payment.amount,
#       currency: "ZMW",
#       payment_method: payment.method,
#       payment_status: payment.status,
#       payment_date: DateTime.utc_now(),
#       payer_name: payment.payer_name,
#       payer_phone: payment.phone_number,
#       giving_type: payment.giving_type,
#       payment_reference: payment.reference_id
#     }

#     %Receipt{}
#     |> Receipt.changeset(attrs)
#     |> Repo.insert()
#   end

#   def get_receipt(receipt_number) do
#     Repo.get_by(Receipt, receipt_number: receipt_number)
#   end
# end
