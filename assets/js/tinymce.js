// Initialize TinyMCE
document.addEventListener("DOMContentLoaded", function() {
  const editors = document.querySelectorAll('.tinymce');
  if (editors.length > 0) {
    tinymce.init({
      selector: '.tinymce',
      plugins: 'lists link image table code help wordcount media',
      toolbar: 'undo redo | blocks | bold italic | alignleft aligncenter alignright | indent outdent | bullist numlist | link image media | table | code',
      height: 500,
      menubar: true,
      branding: false,
      promotion: false,
      // Enable automatic URL conversion
      convert_urls: false,
      // Allow HTML tags and attributes
      valid_elements: '*[*]',
      
      // File picker configuration
      file_picker_callback: function(callback, value, meta) {
        // Open custom dialog
        openMediaLibrary(callback, meta);
      },
      
      // Image upload configuration
      images_upload_url: '/777/upload',
      images_upload_handler: function (blobInfo, success, failure, progress) {
        const xhr = new XMLHttpRequest();
        xhr.withCredentials = false;
        xhr.open('POST', '/777/upload');

        // Get CSRF token
        const token = document.querySelector("meta[name='csrf-token']").content;
        xhr.setRequestHeader("x-csrf-token", token);

        xhr.upload.onprogress = function (e) {
          progress(e.loaded / e.total * 100);
        };

        xhr.onload = function() {
          if (xhr.status === 403) {
            failure('HTTP Error: ' + xhr.status, { remove: true });
            return;
          }
          if (xhr.status < 200 || xhr.status >= 300) {
            failure('HTTP Error: ' + xhr.status);
            return;
          }

          const json = JSON.parse(xhr.responseText);
          if (!json || typeof json.location != 'string') {
            failure('Invalid JSON: ' + xhr.responseText);
            return;
          }

          success(json.location);
        };

        xhr.onerror = function () {
          failure('Image upload failed due to a network error');
        };

        const formData = new FormData();
        formData.append('file', blobInfo.blob(), blobInfo.filename());

        xhr.send(formData);
      }
    });
  }
});

// Media Library Dialog
function openMediaLibrary(callback, meta) {
  // Create modal
  const modal = document.createElement('div');
  modal.className = 'fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50';
  modal.innerHTML = `
    <div class="relative top-20 mx-auto p-5 border w-11/12 md:w-3/4 shadow-lg rounded-md bg-white">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-medium">Media Library</h3>
        <button class="modal-close text-gray-400 hover:text-gray-500">
          <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
      <div id="media-content" class="grid grid-cols-2 md:grid-cols-4 gap-4 max-h-96 overflow-y-auto">
        Loading...
      </div>
    </div>
  `;

  document.body.appendChild(modal);

  // Close button handler
  modal.querySelector('.modal-close').onclick = function() {
    document.body.removeChild(modal);
  };

  // Load media items
  fetch('/777/media?format=json', {
    headers: {
      'Accept': 'application/json'
    }
  })
  .then(response => response.json())
  .then(data => {
    const mediaContent = modal.querySelector('#media-content');
    mediaContent.innerHTML = data.uploads.map(upload => `
      <div class="media-item cursor-pointer hover:opacity-75" data-url="${upload.path}">
        ${upload.content_type.startsWith('image/') 
          ? `<img src="${upload.path}" alt="${upload.filename}" class="w-full h-32 object-cover rounded">`
          : `<div class="w-full h-32 flex items-center justify-center bg-gray-100 rounded">
              <svg class="h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
              </svg>
            </div>`
        }
        <p class="mt-1 text-sm text-gray-500 truncate">${upload.filename}</p>
      </div>
    `).join('');

    // Add click handlers
    mediaContent.querySelectorAll('.media-item').forEach(item => {
      item.onclick = function() {
        const url = this.dataset.url;
        callback(url, { title: this.querySelector('p').textContent });
        document.body.removeChild(modal);
      };
    });
  });
} 