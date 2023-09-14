defmodule LeafNodeWeb.Web.PageStaticController do
  @moduledoc """
    The page controller that deals with the data entry point for rendering the views data
  """
  use LeafNodeWeb, :controller

  # The base layout
  @app_layout {LeafNodeWeb.Layouts, "app.html"}


  @doc """
    view: documents
    Documents list view
  """
  def documents(conn, _params) do
    render(conn, :documents, layout: @app_layout)
  end

  @doc """
    view: document
    Single Document by id that we want to render
  """
  def document(conn, _params) do
    render(conn, :document, layout: @app_layout)
  end

  @doc """
    view: masking
    Masking urls to be able to reuse urls for documents
  """
  def masking(conn, _params) do
    render(conn, :masking, layout: @app_layout)
  end

end
