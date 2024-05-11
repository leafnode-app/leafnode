defmodule LeafNodeWeb.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  # Auth
  alias LeafNodeWeb
  # API
  alias LeafNodeWeb.Web
  # alias LeafNodeWeb.Api.{DocumentController, TextController}

  import LeafNodeWeb.UserAuth

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

  pipeline :validate_access_key do
    plug LeafNodeWeb.Plugs.AccessKeyAuth
  end

  # Landing Page
  scope "/", LeafNodeWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live "/", UserLoginLive
  end

  # App dashboard - login
  scope "/dashboard", Web do
    pipe_through [:browser, :require_authenticated_user]

    live "/", Live.Nodes
    live "/node/:id", Live.Node
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

  scope "/auth", LeafNodeWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{LeafNodeWeb.UserAuth, :ensure_authenticated}] do
      live "/settings", UserSettingsLive, :edit
      live "/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/auth/", LeafNodeWeb do
    pipe_through [:browser]

    delete "/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{LeafNodeWeb.UserAuth, :mount_current_user}] do
      live "/confirm/:token", UserConfirmationLive, :edit
      live "/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  # scope "/api/v1/documents" do
  #   pipe_through :api
  #   # TODO: add the access key validation here
  #   # TODO: Separate the execution code and crud operations/transactions for documents
  #   # pipe_through :validate_access_key

  #   post "/create", DocumentController, :create_document
  #   post "/execute/:id", DocumentController, :execute_document
  #   post "/execute_verbose/:id", DocumentController, :execute_document_verbose
  #   delete "/:id", DocumentController, :delete_document
  #   put "/:id", DocumentController, :update_document
  #   get "/", DocumentController, :get_documents
  #   get "/list", DocumentController, :get_documents_list
  #   get "/:id", DocumentController, :get_document_by_id
  # end

  # scope "/api/v1/text" do
  #   pipe_through :api
  #   # TODO: add the access key validation here
  #   # TODO: Separate the execution code and crud operations/transactions for documents
  #   # pipe_through :validate_access_key

  #   # we need to pass through the parent document id
  #   get "/:document_id/list", TextController, :get_documents_texts_list
  #   post "/:document_id/create", TextController, :create_text
  #   post "/:id/generate_code", TextController, :generate_code
  #   put "/:id", TextController, :update_text
  #   delete "/:id", TextController, :delete_text
  #   get "/:id", TextController, :get_text_by_id
  # end

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
