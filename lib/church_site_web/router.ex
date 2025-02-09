defmodule ChurchSiteWeb.Router do
  use ChurchSiteWeb, :router

  import ChurchSiteWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ChurchSiteWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :require_admin do
    plug ChurchSiteWeb.Plugs.AdminAuth
  end

  pipeline :require_authenticated_user do
    plug ChurchSiteWeb.Plugs.RequireAuth
  end

  scope "/", ChurchSiteWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/contact", PageController, :contact
    get "/uploads/*path", UploadsController, :show
    get "/images/*path", UploadsController, :show

    # About section
    get "/about", PageController, :about
    get "/about/history", PageController, :history
    get "/about/beliefs", PageController, :beliefs
    get "/about/pastor", PageController, :pastor

    # Members section
    get "/members", PageController, :members
    get "/members/directory", PageController, :directory
    get "/members/calendar", PageController, :calendar
    get "/members/ministries", PageController, :ministries

    # Community section
    get "/community", PageController, :community
    get "/community/children", PageController, :children
    get "/community/youth", PageController, :youth
    get "/community/announcements", PageController, :announcements

    # Other main sections
    get "/events", PageController, :events
    get "/giving", PageController, :giving
    get "/receipts/:receipt_number", ReceiptController, :show

    # Receipt routes
    # get "/receipt/:receipt_number", PaymentController, :show_receipt
    # Add this line to serve static assets
    get "/assets/*path", AssetsController, :show

    resources "/media", MediaController
  end

  scope "/api", ChurchSiteWeb do
    pipe_through :api

    post "/payments/initiate", PaymentController, :initiate
    get "/payments/status/:reference_id", PaymentController, :check_status
  end

  # Admin authentication routes
  scope "/777", ChurchSiteWeb.Admin do
    pipe_through [:browser]  # Remove :require_admin for login routes

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete
  end

  # Protected admin routes
  scope "/777", ChurchSiteWeb.Admin do
    pipe_through [:browser, :require_admin]

    get "/dashboard", DashboardController, :index
    get "/", DashboardController, :index
    resources "/announcements", AnnouncementController
    resources "/payments", PaymentController
    get "/receipts/export", ReceiptController, :export_csv
    resources "/receipts", ReceiptController, only: [:index, :show]
    resources "/pages", PageController  # For editing static pages
    resources "/blog_posts", BlogPostController
    resources "/media", MediaController
    post "/upload", UploadController, :create
    delete "/upload/:id", UploadController, :delete
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:church_site, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ChurchSiteWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/admin", ChurchSiteWeb.Admin do
    pipe_through [:browser, :require_admin]

    resources "/media", MediaController
  end

  scope "/777", ChurchSiteWeb.Admin, as: :admin do
    pipe_through [:browser, :require_authenticated_user]

    live "/media", MediaLive.Index, :index
  end

  # Static file serving
  scope "/uploads", ChurchSiteWeb do
    pipe_through :browser

    get "/*path", UploadsController, :show
  end
end
