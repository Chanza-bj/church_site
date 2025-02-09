document.addEventListener('DOMContentLoaded', function() {
  // Find all OK buttons in payment status modals
  const okButtons = document.querySelectorAll('.payment-status button, button.OK, #payment-status-ok');
  okButtons.forEach(button => {
      button.addEventListener('click', function(e) {
          e.preventDefault();
          e.stopPropagation();
          
          // Find and hide the modal
          const modal = this.closest('.payment-status, .modal');
          if (modal) {
              modal.style.display = 'none';
          }
          
          // Clear the form without reloading
          const form = document.getElementById('payment-form');
          if (form) {
              form.reset();
          }
      });
  });
});

document.getElementById('payment-form').addEventListener('submit', async (e) => {
  e.preventDefault();

  const amount = document.getElementById('amount').value;
  const phoneNumber = document.getElementById('phone').value;
  const givingType = document.getElementById('giving-type').value;

  try {
      const response = await fetch('/api/payments/initiate', {
          method: 'POST',
          headers: {
              'Content-Type': 'application/json',
          },
          body: JSON.stringify({
              amount: amount,
              method: 'mtn',
              phone_number: phoneNumber,
              giving_type: givingType
          })
      });

      const data = await response.json();
      if (data.success) {
          checkPaymentStatus(data.referenceId);
      } else {
          showPaymentError(data.message || "Payment initiation failed.");
      }
  } catch (error) {
      showPaymentError("Network error. Please try again.");
  }
});

function checkPaymentStatus(referenceId) {
  let attempts = 0;
  const maxAttempts = 30;
  let timeoutId = null;

  async function pollStatus() {
      if (attempts >= maxAttempts) {
          console.error("Max polling attempts reached.");
          showPaymentError("Payment timeout. Please check your phone for the status.");
          return;
      }

      try {
          const response = await fetch(`/api/payments/status/${referenceId}`);
          const data = await response.json();

          console.log("Payment status response:", data);

          if (data.success) {
              if (data.status === "COMPLETED" || data.shouldStopPolling) {
                  console.log("Payment completed, stopping poll");
                  if (data.status === "COMPLETED") {
                      // Update the existing modal content
                      const modalTitle = document.querySelector('.payment-status h2');
                      if (modalTitle) modalTitle.textContent = 'Payment Status';
                      
                      const modalMessage = document.querySelector('.payment-status .status-message');
                      if (modalMessage) {
                          modalMessage.innerHTML = `
                              <p>Payment completed successfully</p>
                              <a href="/receipts/${data.receipt_number}" target="_blank" class="receipt-link">View Receipt (${data.receipt_number})</a>
                          `;
                      }
                  }
                  return;
              } else if (data.status === "FAILED") {
                  console.log("Payment failed, stopping poll");
                  showPaymentError("Payment failed.");
                  return;
              } else {
                  attempts++;
                  const delay = Math.min(Math.pow(2, attempts) * 1000, 5000);
                  console.log(`Payment pending, polling again in ${delay}ms`);
                  timeoutId = setTimeout(pollStatus, delay);
              }
          } else {
              console.log("Payment check failed:", data.message);
              showPaymentError(data.message || "Error checking payment status.");
              return;
          }
      } catch (error) {
          console.error("Payment check error:", error);
          showPaymentError("Network error. Please try again.");
          return;
      }
  }

  pollStatus();

  return () => {
      if (timeoutId) {
          clearTimeout(timeoutId);
      }
  };
}

function showPaymentError(message) {
  alert("Payment error: " + message);
}

let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: {
    StickyHeader: {
      mounted() {
        const stickyNav = document.getElementById('homeStickyNav') || document.getElementById('stickyNav');
        if (!stickyNav) return; // Guard clause if element doesn't exist
        
        function handleScroll() {
          if (window.scrollY > 100) {
            stickyNav.style.display = 'block';
            setTimeout(() => {
              stickyNav.classList.add('visible');
            }, 10);
          } else {
            stickyNav.classList.remove('visible');
            setTimeout(() => {
              stickyNav.style.display = 'none';
            }, 300);
          }
        }

        window.addEventListener('scroll', handleScroll);
        this.handleScroll = handleScroll;
      },

      destroyed() {
        if (this.handleScroll) {
          window.removeEventListener('scroll', this.handleScroll);
        }
      }
    }
  }
})
