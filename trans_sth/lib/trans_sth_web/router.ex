defmodule TransSthWeb.Router do
  use TransSthWeb, :router

  pipeline :browser do
    plug(:accepts, ["html", "json"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {TransSthWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    # plug TransSth.Plugs.Locale, "en"
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", TransSthWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
    get("/:messenger", ShowController, :show)
    # resources "/users", UserController
  end

  # Other scopes may use custom stacks.
  scope "/api", TransSthWeb do
    pipe_through(:api)

    post("/trans_file", ApiController, :trans_file)
    post("/trans_text", ApiController, :trans_text)
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:trans_sth, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: TransSthWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
