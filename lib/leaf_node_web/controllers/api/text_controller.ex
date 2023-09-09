defmodule LeafNodeWeb.Api.TextController do
  @moduledoc """
    Text controller that does transactions of paragraphs linked to documents
  """
  use LeafNodeWeb, :controller

  import Plug.Conn
  require Logger
  alias LeafNode.Utils.Helpers, as: Helpers

  @doc """
    Get all documents keys as a list
  """
  def get_documents_texts_list(conn, %{ "document_id" => id}) do
    case LeafNode.Core.Text.list_texts(id) do
      {:ok, data} ->
        return(conn, 200, Helpers.http_resp(200, true, Enum.map(data, fn item -> item.id end)))
      {:error, err} ->
        return(conn, 404, Helpers.http_resp(404, false, err))
    end
  end

  @doc """
    Create new text for document
  """
  def create_text(conn, params) do
    case LeafNode.Core.Text.create_text(params) do
      {:ok, data} ->
        return(conn, 200, Helpers.http_resp(200, true, data))
      {:error, err} ->
        return(conn, 404, Helpers.http_resp(404, false, err))
    end
  end

  @doc """
    Generate code for text
  """
  def generate_code(conn, %{ "id" => id}) do
    case LeafNode.Core.Text.generate_code(id) do
      {:ok, data} ->
        return(conn, 200, Helpers.http_resp(200, true, data))
      {:error, err} ->
        return(conn, 404, Helpers.http_resp(404, false, err))
    end
  end

  @doc """
    Update text data
  """
  def update_text(conn, params) do
    case LeafNode.Core.Text.edit_text(params) do
      {:ok, data} ->
        return(conn, 200, Helpers.http_resp(200, true, data))
      {:error, err} ->
        return(conn, 404, Helpers.http_resp(404, false, err))
    end
  end

  @doc """
    Delete document text
  """
  def delete_text(conn, %{ "id" => id}) do
    # TODO: use the function to delete: LeafNode.Core.Text.delete_text(id) - we soft delete text
    case LeafNode.Core.Text.edit_text(%{
        "id" => id,
        "is_deleted" => "true"
      }) do
      {:ok, data} ->
        return(conn, 200, Helpers.http_resp(200, true, data))
      {:error, err} ->
        return(conn, 404, Helpers.http_resp(404, false, err))
    end
  end

 @doc """
    Get text details by id
  """
  def get_text_by_id(conn, %{"id" => id}) do
    case LeafNode.Core.Text.get_text(id) do
      {:ok, data} ->
        return(conn, 200, Helpers.http_resp(200, true, data))
      {:error, err} ->
        return(conn, 404, Helpers.http_resp(404, false, err))
    end
  end

  # JSON returned response helper method for the controller functions
  defp return(conn, status, data) do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Jason.encode!(data))
  end
end
