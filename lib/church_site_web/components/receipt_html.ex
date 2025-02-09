defmodule ChurchSiteWeb.ReceiptHTML do
  use ChurchSiteWeb, :html

  def show(assigns) do
    ~H"""
    <div class="receipt-container">
      <div class="receipt-header">
        <img src={~p"/images/sda-logo.png"} alt="SDA Logo" class="church-logo" />
        <h2><%= @church_name %></h2>
        <p>Seventh-day Adventist Church</p>
        <p><%= @church_address %></p>
      </div>

      <div class="receipt-body">
        <h1>RECEIPT</h1>
        <div class="receipt-number">
          Receipt #: <%= @receipt.receipt_number %>
        </div>
        <div class="receipt-date">
          Date: <%= Calendar.strftime(@receipt.payment_date, "%B %d, %Y") %>
        </div>

        <div class="receipt-details">
          <div class="detail-row">
            <span class="label">Received from:</span>
            <span class="value"><%= @receipt.payer_name %></span>
          </div>
          <div class="detail-row">
            <span class="label">Phone:</span>
            <span class="value"><%= @receipt.payer_phone %></span>
          </div>
          <div class="detail-row">
            <span class="label">Amount:</span>
            <span class="value"><%= @receipt.currency %> <%= :erlang.float_to_binary(Decimal.to_float(@receipt.amount), decimals: 2) %></span>
          </div>
          <div class="detail-row">
            <span class="label">Payment type:</span>
            <span class="value"><%= @receipt.giving_type %></span>
          </div>
          <div class="detail-row">
            <span class="label">Payment method:</span>
            <span class="value"><%= @receipt.payment_method %></span>
          </div>
          <div class="detail-row">
            <span class="label">Reference:</span>
            <span class="value"><%= @receipt.payment_reference %></span>
          </div>
        </div>

        <div class="receipt-footer">
          <p>Thank you for your generous contribution!</p>
          <small>This is a computer-generated receipt and does not require a signature.</small>
        </div>
      </div>
    </div>
    """
  end
end
