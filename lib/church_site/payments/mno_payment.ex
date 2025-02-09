defmodule ChurchSite.Payments.MNOPayment do
  @mtn_api_url "https://sandbox.momodeveloper.mtn.com/collection"
  @airtel_api_url "https://openapiuat.airtel.africa"

  def initiate_payment(method, amount, phone_number) do
    case method do
      "mtn" -> initiate_mtn_payment(amount, phone_number)
      "airtel" -> initiate_airtel_payment(amount, phone_number)
    end
  end

  defp initiate_mtn_payment(amount, phone_number) do
    headers = [
      {"Authorization", "Bearer #{get_mtn_token()}"},
      {"X-Reference-Id", generate_reference_id()},
      {"X-Target-Environment", "sandbox"},
      {"Content-Type", "application/json"}
    ]

    body = Jason.encode!(%{
      amount: amount,
      currency: "ZMW",
      externalId: generate_reference_id(),
      payer: %{
        partyIdType: "MSISDN",
        partyId: phone_number
      },
      payerMessage: "Church Donation",
      payeeNote: "Thank you for your gift"
    })

    HTTPoison.post("#{@mtn_api_url}/collection/v1_0/requesttopay", body, headers)
  end

  defp initiate_airtel_payment(amount, phone_number) do
    headers = [
      {"Authorization", "Bearer #{get_airtel_token()}"},
      {"Content-Type", "application/json"}
    ]

    body = Jason.encode!(%{
      reference: generate_reference_id(),
      subscriber: %{
        country: "ZM",
        currency: "ZMW",
        msisdn: phone_number
      },
      transaction: %{
        amount: amount,
        country: "ZM",
        currency: "ZMW",
        id: generate_reference_id()
      }
    })

    HTTPoison.post("#{@airtel_api_url}/merchant/v1/payments/", body, headers)
  end

  # Add these to config/config.exs
  defp get_mtn_token do
    # Implementation to get OAuth token from MTN API
    System.get_env("MTN_API_TOKEN")
  end

  defp get_airtel_token do
    # Implementation to get OAuth token from Airtel API
    System.get_env("AIRTEL_API_TOKEN")
  end

  defp generate_reference_id, do: UUID.uuid4()
end
