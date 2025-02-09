# defmodule ChurchSite.MtnMomo do
#   use Tesla
#   require Logger

#   @base_url "https://sandbox.momodeveloper.mtn.com"
#   @subscription_key "22329f20ab5e449d98c17718efb2512e"
#   @api_user "743bbc3a-6d25-4656-8452-fa6652842b6b"
#   @api_key "0c029810ab0a4140b5512bd50bf9d1ec"

#   plug Tesla.Middleware.BaseUrl, @base_url
#   plug Tesla.Middleware.JSON

#   def get_token do
#     credentials = Base.encode64("#{@api_user}:#{@api_key}")

#     headers = [
#       {"Authorization", "Basic #{credentials}"},
#       {"Ocp-Apim-Subscription-Key", @subscription_key}
#     ]

#     case post("/collection/token/", "", headers: headers) do
#       {:ok, %{status: 200, body: %{"access_token" => token}}} ->
#         {:ok, token}
#       error ->
#         Logger.error("Token error: #{inspect(error)}")
#         {:error, "Failed to get token"}
#     end
#   end

#   def request_payment(amount, phone_number, giving_type, payer_name) do
#     case get_token() do
#       {:ok, token} ->
#         reference_id = UUID.uuid4()
#         external_id = UUID.uuid4()

#         headers = [
#           {"X-Reference-Id", reference_id},
#           {"X-Target-Environment", "sandbox"},
#           {"Ocp-Apim-Subscription-Key", @subscription_key},
#           {"Authorization", "Bearer #{token}"}
#         ]

#         body = %{
#           "amount" => amount,
#           "currency" => "EUR",
#           "externalId" => external_id,
#           "payer" => %{
#             "partyIdType" => "MSISDN",
#             "partyId" => phone_number
#           },
#           "payerMessage" => "#{giving_type} Offering",
#           "payeeNote" => "Thank you #{payer_name} for your #{String.downcase(giving_type)} offering"
#         }

#         case post("/collection/v1_0/requesttopay", body, headers: headers) do
#           {:ok, %{status: 202}} ->
#             Logger.info("Payment request successful. Reference ID: #{reference_id}")
#             {:ok, reference_id}
#           {:ok, response} ->
#             Logger.error("Payment error response: #{inspect(response)}")
#             {:error, response.body["message"] || "Payment request failed"}
#           {:error, error} ->
#             Logger.error("Payment error: #{inspect(error)}")
#             {:error, "Payment request failed"}
#         end

#       {:error, error} ->
#         Logger.error("Token error: #{inspect(error)}")
#         {:error, "Authentication failed"}
#     end
#   end

#   def check_status(reference_id) do
#     case get_token() do
#       {:ok, token} ->
#         headers = [
#           {"X-Target-Environment", "sandbox"},
#           {"Ocp-Apim-Subscription-Key", @subscription_key},
#           {"Authorization", "Bearer #{token}"}
#         ]

#         case get("/collection/v1_0/requesttopay/#{reference_id}", headers: headers) do
#           {:ok, %{status: 200, body: body}} ->
#             status = get_readable_status(body)
#             Logger.info("Payment status: #{status}")
#             {:ok, body}
#           error ->
#             Logger.error("Status check error: #{inspect(error)}")
#             {:error, "Failed to check status"}
#         end

#       error ->
#         error
#     end
#   end

#   def get_payment_status(reference_id) do
#     case check_status(reference_id) do
#       {:ok, %{"status" => status}} -> {:ok, status}
#       error -> error
#     end
#   end

#   defp get_readable_status(%{"status" => status} = body) do
#     case status do
#       "PENDING" -> "Payment is pending approval from #{body["payer"]["partyId"]}"
#       "SUCCESSFUL" -> "Payment of #{body["amount"]} #{body["currency"]} was successful"
#       "FAILED" -> "Payment failed"
#       _ -> "Unknown status: #{status}"
#     end
#   end
# end
