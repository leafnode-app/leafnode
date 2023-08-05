defmodule LeafNodeWeb.Web.PageController do
  @moduledoc """
    The page controller that deals with the data entry point for rendering the views data
  """
  use LeafNodeWeb, :controller

  @doc """
    view: home
  """
  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

end
