defmodule ChurchSiteWeb.Components.StickyMenu do
  use Phoenix.Component

  def sticky_menu(assigns) do
    ~H"""
    <div id="sticky-menu" style="display: none; position: fixed; top: 0; left: 0; right: 0; background: #1B3F8F; z-index: 1000;">
      <div style="display: flex; justify-content: space-between; padding: 1rem;">
        <div style="color: white;">Church Name</div>
        <nav>
          <ul style="display: flex; gap: 1rem; list-style: none; margin: 0; padding: 0;">
            <li><a href="/" style="color: white; text-decoration: none;">HOME</a></li>
            <li><a href="/about" style="color: white; text-decoration: none;">ABOUT</a></li>
            <li><a href="/contact" style="color: white; text-decoration: none;">CONTACT</a></li>
          </ul>
        </nav>
      </div>
    </div>

    <script>
      window.addEventListener('scroll', function() {
        const menu = document.getElementById('sticky-menu');
        if (window.scrollY > 100) {
          menu.style.display = 'block';
        } else {
          menu.style.display = 'none';
        }
      });
    </script>
    """
  end
end
