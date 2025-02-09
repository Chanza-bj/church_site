defmodule ChurchSite.AirtelMoney do
  use Tesla
  require Logger

  @base_url "https://openapiuat.airtel.africa"
  @client_id "your_client_id"
  @client_secret "your_client_secret"
  @country_code "ZM"  # Zambia
  @currency "ZMW"

  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.JSON

  def get_token do
    headers = [
      {"Content-Type", "application/json"},
      {"Accept", "*/*"}
    ]

    body = %{
      "client_id" => @client_id,
      "client_secret" => @client_secret,
      "grant_type" => "client_credentials"
    }

    case post("/auth/oauth2/token", body, headers: headers) do
      {:ok, %{status: 200, body: %{"access_token" => token}}} ->
        {:ok, token}
      error ->
        Logger.error("Airtel token error: #{inspect(error)}")
        {:error, "Failed to get authentication token"}
    end
  end

  def request_payment(amount, phone_number, giving_type, payer_name) do
    case get_token() do
      {:ok, token} ->
        reference_id = UUID.uuid4()

        headers = [
          {"Content-Type", "application/json"},
          {"Accept", "*/*"},
          {"X-Country", @country_code},
          {"X-Currency", @currency},
          {"Authorization", "Bearer #{token}"}
        ]

        body = %{
          "reference" => reference_id,
          "subscriber" => %{
            "country" => @country_code,
            "currency" => @currency,
            "msisdn" => phone_number
          },
          "transaction" => %{
            "amount" => amount,
            "country" => @country_code,
            "currency" => @currency,
            "id" => reference_id
          },
          "message" => "#{giving_type} Offering - Thank you #{payer_name}"
        }

        case post("/merchant/v1/payments/", body, headers: headers) do
          {:ok, %{status: 200, body: response}} ->
            Logger.info("Airtel payment request successful: #{inspect(response)}")
            {:ok, reference_id}
          error ->
            Logger.error("Airtel payment error: #{inspect(error)}")
            {:error, "Payment request failed"}
        end

      error ->
        error
    end
  end

  def check_status(reference_id) do
    case get_token() do
      {:ok, token} ->
        headers = [
          {"Content-Type", "application/json"},
          {"Accept", "*/*"},
          {"X-Country", @country_code},
          {"X-Currency", @currency},
          {"Authorization", "Bearer #{token}"}
        ]

        case get("/standard/v1/payments/#{reference_id}", headers: headers) do
          {:ok, %{status: 200, body: body}} ->
            Logger.info("Payment status: #{inspect(body)}")
            {:ok, body}
          error ->
            Logger.error("Status check error: #{inspect(error)}")
            {:error, "Failed to check payment status"}
        end

      error ->
        error
    end
  end
end
