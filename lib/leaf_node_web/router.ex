defmodule LeafNodeWeb.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router
  import LeafNodeWeb.UserAuth
  alias LeafNodeWeb
  alias LeafNodeWeb.Api.{NodeController}

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LeafNodeWeb.Layouts, :root}
    # We dont need this for a self host app that will be used with the system for now
    # Make sure to change this and add if making multi client hosted application
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :endpoint_access_validation do
    plug LeafNodeWeb.Plugs.AccessKeyAuth
    plug LeafNodeWeb.Plugs.CheckContentType
  end

  pipeline :extension_access do
    plug LeafNodeWeb.Plugs.ExtensionKeyAuth
  end

  pipeline :node_email_check do
    plug LeafNodeWeb.Plugs.NodeEmailCheck
  end

  # Landing Page
  scope "/", LeafNodeWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live "/", UserLoginLive

    # TODO: privacy policy and terms of service - make sure to update google and services that need this
    # live "/privacy-policy", GeneralLive, :privacy_policy
    # live "/terms-of-service", GeneralLive, :terms_of_service
  end

  ## Authentication routes
  scope "/auth", LeafNodeWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{LeafNodeWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/register", UserRegistrationLive, :new
      live "/log_in", UserLoginLive, :new
      live "/reset_password", UserForgotPasswordLive, :new
      live "/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/log_in", UserSessionController, :create
  end

  # App dashboard - login
  scope "/", LeafNodeWeb do
    pipe_through [:browser]

    delete "/auth/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{LeafNodeWeb.UserAuth, :mount_current_user}] do
      live "/auth/confirm/:token", UserConfirmationLive, :edit
      live "/auth/confirm", UserConfirmationInstructionsLive, :new

      # Integrations and OAuth redirects
      # Google
      # get "/auth/google/request/:node_id", GoogleController, :request
      # get "/auth/google/callback", GoogleController, :callback
      # Notion
      get "/auth/notion/request/:node_id", NotionController, :request
      get "/auth/notion/callback", NotionController, :callback
    end
  end

  scope "/", LeafNodeWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{LeafNodeWeb.UserAuth, :ensure_authenticated}] do
      live "/dashboard/", NodesLive
      live "/dashboard/node/:id", NodeLive
      live "/dashboard/log/:id", LogDetailsLive
      live "/auth/settings", UserSettingsLive, :edit
      live "/auth/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  # API for node execution
  # scope "/api/node" do
  #   pipe_through [:api, :endpoint_access_validation]
  #   post "/:id", NodeController, :execute_node
  # end

  # API for extension interactions with user data
  # TODO: change this so the naming is better to make it easier to impport
  # scope "/api/extension" do
  #   pipe_through [:api, :extension_access]
  #   get "/nodes", LeafNodeWeb.ExtensionApi.NodeController, :get_nodes
  # end
  # scope "/api/extension" do
  #   pipe_through [:api, :extension_access]
  #   post "/node/:id", LeafNodeWeb.ExtensionApi.NodeController, :execute_node
  # end

  # Internal routes to trigger and execute nodes
  scope "/internal", LeafNodeWeb do
    # TODO: add plug to confirm keys between services
    pipe_through [:node_email_check, :api]
    post "/trigger/:email", InternalController, :trigger
  end

  # ---- API ---- #
  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:leaf_node, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LeafNodeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # Add a catch-all route at the end of your router
  scope "/", LeafNodeWeb do
    get "/*path", NoAccessController, :get_route_not_found
    post "/*path", NoAccessController, :post_route_not_found
  end
end
