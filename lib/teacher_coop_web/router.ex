defmodule TeacherCoopWeb.Router do
  use TeacherCoopWeb, :router

  import TeacherCoopWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TeacherCoopWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TeacherCoopWeb do
    pipe_through :browser
  end

  # Other scopes may use custom stacks.
  # scope "/api", TeacherCoopWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:teacher_coop, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TeacherCoopWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", TeacherCoopWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TeacherCoopWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/workspace", TeacherCoopWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :workspace,
      on_mount: [{TeacherCoopWeb.UserAuth, :require_authenticated}] do
      live "/", WorkspaceLive.Workspace, :index

      live "/documents", WorkspaceLive.DocumentLive.Index, :index
      live "/documents/new", WorkspaceLive.DocumentLive.Form, :new
      live "/documents/:id/edit", WorkspaceLive.DocumentLive.Form, :edit
      live "/documents/:id", WorkspaceLive.DocumentLive.Show, :show

      live "/groups", WorkspaceLive.GroupLive.Index, :index
      live "/groups/new", WorkspaceLive.GroupLive.Form, :new
      live "/groups/:id/edit", WorkspaceLive.GroupLive.Form, :edit
      live "/groups/:id", WorkspaceLive.GroupLive.Show, :show
    end
  end

  scope "/", TeacherCoopWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{TeacherCoopWeb.UserAuth, :mount_current_scope}] do
      live "/", SearchLive, :search
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
