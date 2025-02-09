defmodule ChurchSiteWeb.PaymentController do
  use ChurchSiteWeb, :controller

  alias ChurchSite.Payments
  alias ChurchSite.Receipts
  alias ChurchSite.MtnMomo

  def initiate(conn, params) do
    giving_type = params["giving_type"]
                 |> String.downcase()
                 |> String.replace(" ", "_")

    reference_id = UUID.uuid4()

    payment_params = %{
      amount: params["amount"],
      payer_name: params["payer_name"],
      giving_type: giving_type,
      phone_number: params["phone_number"],
      method: String.upcase(params["method"]),
      reference_id: reference_id,
      status: "pending"
    }

    IO.puts("Creating payment with params: #{inspect(payment_params)}")

    case Payments.create_payment(payment_params) do
      {:ok, payment} ->
        case MtnMomo.request_payment(payment.amount, payment.phone_number, payment.reference_id) do
          {:ok, _momo_response} ->
            json(conn, %{
              success: true,
              reference: payment.reference_id,
              message: "Payment initiated successfully"
            })

          {:error, momo_error} ->
            conn
            |> put_status(:service_unavailable)
            |> json(%{
              success: false,
              message: "Failed to initiate mobile money payment: #{momo_error}"
            })
        end

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          success: false,
          message: "Invalid payment request",
          errors: error_messages(changeset)
        })
    end
  end

  def check_status(conn, %{"reference_id" => reference_id}) do
    IO.puts("\n=== Starting status check for reference_id: #{reference_id} ===")

    case Payments.get_payment_by_reference(reference_id) do
      nil ->
        IO.puts("Payment not found in database")
        json(conn, %{
          success: false,
          message: "Payment not found"
        })

      payment ->
        IO.puts("Found payment in database: #{inspect(payment, pretty: true)}")

        if payment.status == "completed" do
          # Try to get or create receipt
          receipt = case Receipts.get_receipt_by_payment_reference(payment.reference_id) do
            nil ->
              IO.puts("No receipt found, creating one...")
              case Receipts.create_receipt_from_payment(payment) do
                {:ok, new_receipt} -> new_receipt
                {:error, _} -> nil
              end
            existing_receipt ->
              IO.puts("Found existing receipt: #{existing_receipt.receipt_number}")
              existing_receipt
          end

          case receipt do
            nil ->
              conn |> json(%{
                success: false,
                status: "COMPLETED",
                message: "Payment completed but failed to generate receipt"
              })
            receipt ->
              conn |> json(%{
                success: true,
                status: "COMPLETED",
                receipt_number: receipt.receipt_number,
                shouldStopPolling: true
              })
          end
        else
          IO.puts("Checking MTN MOMO status...")
          check_mtn_status(conn, payment)
        end
    end
  end

  defp check_mtn_status(conn, payment) do
    case MtnMomo.check_status(payment.reference_id) do
      {:ok, "SUCCESSFUL"} ->
        IO.puts("MTN status is SUCCESSFUL, updating payment...")

        case Payments.update_payment(payment, %{status: "completed"}) do
          {:ok, updated_payment} ->
            # Generate receipt immediately after successful payment
            case Receipts.create_receipt_from_payment(updated_payment) do
              {:ok, receipt} ->
                json(conn, %{
                  success: true,
                  status: "COMPLETED",
                  message: "Payment completed successfully",
                  shouldStopPolling: true,
                  receipt_number: receipt.receipt_number
                })

              {:error, _} ->
                json(conn, %{
                  success: true,
                  status: "COMPLETED",
                  message: "Payment completed successfully, but receipt generation failed",
                  shouldStopPolling: true
                })
            end

          {:error, _changeset} ->
            json(conn, %{
              success: false,
              status: "PENDING",
              message: "Failed to update payment status"
            })
        end

      {:ok, "FAILED"} ->
        IO.puts("MTN status is FAILED, updating payment...")

        case Payments.update_payment(payment, %{status: "failed"}) do
          {:ok, updated_payment} ->
            IO.puts("Payment marked as failed: #{inspect(updated_payment, pretty: true)}")
            json(conn, %{
              success: false,
              status: "FAILED",
              message: "Payment failed",
              shouldStopPolling: true
            })

          {:error, changeset} ->
            IO.puts("Failed to update payment: #{inspect(changeset)}")
            json(conn, %{
              success: false,
              status: "PENDING",
              message: "Failed to update payment status"
            })
        end

      {:ok, "PENDING"} ->
        IO.puts("MTN status is still PENDING")
        json(conn, %{
          success: true,
          status: "PENDING",
          message: "Payment is being processed"
        })

      {:error, message} ->
        IO.puts("Error checking MTN status: #{message}")
        json(conn, %{
          success: false,
          status: "PENDING",
          message: "Error checking payment status"
        })
    end
  end

  def show_receipt(conn, %{"receipt_number" => receipt_number}) do
    case Receipts.get_receipt(receipt_number) do
      nil ->
        conn
        |> put_flash(:error, "Receipt not found")
        |> redirect(to: "/")

      receipt ->
        render(conn, :receipt,
          receipt: receipt,
          church_name: "Evelyn Hone",
          church_address: "Your Church Address"
        )
    end
  end

  defp error_messages(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
