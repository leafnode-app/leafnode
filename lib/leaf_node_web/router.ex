defmodule LeafNodeWeb.Router do
  # Web
  alias Web.PageController
  # API
  alias LeafNodeWeb.Api.{DocumentController}

  use LeafNodeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LeafNodeWeb.Layouts, :root}
    # We dont need this for a self host app that will be used with the system for now
    # Make sure to change this and add if making multi client hosted application
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :validate_access_key do
    # TODO: THIS NEEDS TO COME FROM ENV VARIABLE - Bearer token creation
    plug LeafNodeWeb.Plugs.AccessKeyAuth
  end

  scope "/api/v1/documents" do
    pipe_through :api
    # TODO: add the access key validation here
    # TODO: Separate the execution code and crud operations/transactions for documents
    # pipe_through :validate_access_key

    post "/create", DocumentController, :create_document
    post "/delete/:id", DocumentController, :delete_document
    post "/execute/:id", DocumentController, :execute_document
    put "/:id", DocumentController, :update_document
    get "/", DocumentController, :get_documents
    get "/list", DocumentController, :get_documents_list
    get "/:id", DocumentController, :get_document_by_id
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
