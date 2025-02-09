defmodule ChurchSiteWeb.PageController do
  use ChurchSiteWeb, :controller
  alias ChurchSite.Content
  alias ChurchSite.Media

  def home(conn, _params) do
    media_items = Media.list_media_items()
    slider_images = Enum.filter(media_items, & &1.type == "slider")
    welcome_image = Media.get_media_item_by_section("welcome_image")
    pastor_signature = Media.get_media_item_by_section("pastor_signature")
    about_images = Media.list_media_items_by_type("about")

    render(conn, :home,
      media_items: media_items,
      slider_images: slider_images,
      welcome_image: welcome_image,
      pastor_signature: pastor_signature,
      about_images: about_images,
      church_name: "Evelyn Hone",
      layout: {ChurchSiteWeb.Layouts, :app}
    )
  end

  def contact(conn, _params) do
    render(conn, :contact, church_name: "Evelyn Hone")
  end

  # About section
  def about(conn, _params), do: render_with_defaults(conn, :about)
  def history(conn, _params), do: render_with_defaults(conn, :history)
  def beliefs(conn, _params), do: render_with_defaults(conn, :beliefs)
  def pastor(conn, _params) do
    leaders = Media.list_media_items()
    |> Enum.filter(&(&1.type == "leader" && &1.status == "active"))
    |> Enum.group_by(&(&1.section))

    render(conn, :pastor,
      church_name: "Evelyn Hone",
      leaders_images: leaders
    )
  end

  # Members section
  def members(conn, _params), do: render_with_defaults(conn, :members)
  def directory(conn, _params), do: render_with_defaults(conn, :directory)
  def calendar(conn, _params), do: render_with_defaults(conn, :calendar)
  def ministries(conn, _params), do: render_with_defaults(conn, :ministries)

  # Community section
  def community(conn, _params), do: render_with_defaults(conn, :community)
  def children(conn, _params), do: render_with_defaults(conn, :children)
  def youth(conn, _params), do: render_with_defaults(conn, :youth)
  def announcements(conn, _params) do
    announcements = Content.list_published_announcements()
    render(conn, :announcements,
      announcements: announcements,
      church_name: "Evelyn Hone",
      phone_number: "123-456-7890",
      email: "contact@church.com",
      address: "123 Church Street",
      website: "www.yourchurch.com"
    )
  end

  # Other sections
  def events(conn, _params), do: render_with_defaults(conn, :events)
  def giving(conn, _params), do: render_with_defaults(conn, :giving)

  # Helper to include common assigns
  defp render_with_defaults(conn, template, additional_assigns \\ []) do
    default_assigns = [
      church_name: "Evelyn Hone",
      email: "contact@churchname.org",
      phone_number: "260-973-767852",
      website: "www.churchname.org"
    ]

    render(conn, template, Keyword.merge(default_assigns, additional_assigns))
  end
end
