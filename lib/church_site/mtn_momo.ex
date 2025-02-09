defmodule ChurchSite.MtnMomo do
  @moduledoc """
  Module for interacting with MTN Mobile Money API.
  """

  use Tesla

  @base_url "https://sandbox.momodeveloper.mtn.com"
  @collection_url "#{@base_url}/collection/v1_0"
  @token_url "#{@base_url}/collection/token"

  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.FollowRedirects
  plug Tesla.Middleware.Logger

  adapter Tesla.Adapter.Hackney, [
    recv_timeout: 30_000,
    ssl_options: [verify: :verify_none]
  ]

  def create_api_user do
    user_id = UUID.uuid4()

    headers = [
      {"X-Reference-Id", user_id},
      {"Ocp-Apim-Subscription-Key", subscription_key()}
    ]

    body = %{
      providerCallbackHost: callback_host()
    }

    case post("/v1_0/apiuser", body, headers: headers) do
      {:ok, %{status: 201}} ->
        {:ok, user_id}
      {:ok, response} ->
        {:error, "Failed to create API user: #{inspect(response)}"}
      {:error, error} ->
        {:error, "Error creating API user: #{inspect(error)}"}
    end
  end

  def create_api_key(user_id) do
    headers = [
      {"Ocp-Apim-Subscription-Key", subscription_key()}
    ]

    case post("/v1_0/apiuser/#{user_id}/apikey", "", headers: headers) do
      {:ok, %{status: 201, body: %{"apiKey" => api_key}}} ->
        {:ok, api_key}
      {:ok, response} ->
        {:error, "Failed to create API key: #{inspect(response)}"}
      {:error, error} ->
        {:error, "Error creating API key: #{inspect(error)}"}
    end
  end

  def get_access_token do
    IO.puts("Getting MTN MOMO access token")

    headers = [
      {"Authorization", "Basic #{basic_auth()}"},
      {"Ocp-Apim-Subscription-Key", subscription_key()}
    ]

    IO.puts("Token request headers: #{inspect(headers)}")

    case post(@token_url, "", headers: headers) do
      {:ok, %{status: 200, body: %{"access_token" => token}}} ->
        IO.puts("Successfully got access token")
        {:ok, token}
      {:ok, response} ->
        IO.puts("Failed to get access token. Response: #{inspect(response)}")
        {:error, "Failed to get access token"}
      {:error, error} ->
        IO.puts("Error getting access token: #{inspect(error)}")
        {:error, "Error getting access token"}
    end
  end

  def request_payment(amount, phone_number, reference_id, description \\ " Offering") do
    case get_access_token() do
      {:ok, token} ->
        headers = [
          {"X-Reference-Id", reference_id},
          {"Authorization", "Bearer #{token}"},
          {"Ocp-Apim-Subscription-Key", subscription_key()},
          {"X-Target-Environment", target_environment()}
        ]

        formatted_phone = phone_number
                         |> String.replace(~r/^\+|^0+/, "")
                         |> String.replace(~r/[^0-9]/, "")

        string_amount = if is_struct(amount, Decimal) do
          Decimal.to_string(amount)
        else
          to_string(amount)
        end

        body = %{
          amount: string_amount,
          currency: "EUR",
          externalId: reference_id,
          payer: %{
            partyIdType: "MSISDN",
            partyId: formatted_phone
          },
          payerMessage: "Please approve payment for #{description}",
          payeeNote: "Payment for #{description}"
        }

        IO.puts("Sending payment request with headers: #{inspect(headers)}")
        IO.puts("Request body: #{inspect(body)}")

        case post("#{@collection_url}/requesttopay", body, headers: headers) do
          {:ok, %{status: 202}} ->
            {:ok, reference_id}
          {:ok, response} ->
            IO.puts("Payment request failed: #{inspect(response)}")
            {:error, "Payment request failed: #{inspect(response)}"}
          {:error, error} ->
            IO.puts("Payment request error: #{inspect(error)}")
            {:error, "Payment request error: #{inspect(error)}"}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  def check_status(reference_id) do
    IO.puts("\n=== Checking MTN MOMO status for reference_id: #{reference_id} ===")

    case get_access_token() do
      {:ok, token} ->
        headers = [
          {"Authorization", "Bearer #{token}"},
          {"Ocp-Apim-Subscription-Key", subscription_key()},
          {"X-Target-Environment", target_environment()}
        ]

        url = "#{@collection_url}/requesttopay/#{reference_id}"
        IO.puts("Making request to: #{url}")
        IO.puts("Headers: #{inspect(headers, pretty: true)}")

        case get(url, headers: headers) do
          {:ok, %{status: 200, body: body}} ->
            IO.puts("Got successful response: #{inspect(body, pretty: true)}")
            {:ok, body["status"]}

          {:ok, %{status: 404}} ->
            IO.puts("Got 404 response, treating as PENDING")
            {:ok, "PENDING"}

          {:ok, response} ->
            IO.puts("Got unexpected response: #{inspect(response, pretty: true)}")
            {:error, "Unexpected response"}

          {:error, error} ->
            IO.puts("Got error: #{inspect(error)}")
            {:error, "Request failed"}
        end

      {:error, error} ->
        IO.puts("Failed to get access token: #{inspect(error)}")
        {:error, "Authentication failed"}
    end
  end

  defp basic_auth do
    user_id = Application.get_env(:church_site, :mtn_momo)[:user_id]
    api_key = Application.get_env(:church_site, :mtn_momo)[:api_key]
    Base.encode64("#{user_id}:#{api_key}")
  end

  defp subscription_key do
    Application.get_env(:church_site, :mtn_momo)[:subscription_key] ||
      raise "MTN MOMO subscription key not configured"
  end

  defp target_environment do
    Application.get_env(:church_site, :mtn_momo)[:environment] || "sandbox"
  end

  defp callback_host do
    Application.get_env(:church_site, :mtn_momo)[:callback_host] ||
      raise "MTN MOMO callback host not configured"
  end

  defp callback_url do
    # Use the callback URL that was configured when creating the API user
    "#{callback_host()}/collection/v1_0/requesttopay"
  end
end
