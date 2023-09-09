defmodule LeafNodeWeb.Api.DocumentController do
  @moduledoc """
    Controller that interfaces with the clients request and all the helpers around the processes
  """
  use LeafNodeWeb, :controller

  import Plug.Conn
  require Logger
  alias LeafNode.Utils.Helpers, as: Helpers

  @doc """
    Get all documents keys as a list
  """
  def get_documents_list(conn, _params) do
    case LeafNode.Core.Documents.list_documents do
      {:ok, data} ->
        return(conn, 200, Helpers.http_resp(200, true, Enum.map(data, fn item -> item.id end)))
      {:error, err} ->
        return(conn, 404, Helpers.http_resp(404, false, err))
    end
  end

  @doc """
    Get all documents
  """
  def get_documents(conn, _params) do
    case LeafNode.Core.Documents.list_documents do
      {:ok, data} ->
        return(conn, 200, Helpers.http_resp(200, true, data))
      {:error, err} ->
        return(conn, 404, Helpers.http_resp(404, false, err))
    end
  end

  @doc """
    Get document by id
  """
  def get_document_by_id(conn, %{ "id" => id}) do
    case LeafNode.Core.Documents.get_document(id) do
      {:ok, data} ->
        # We return only the id - less data over the wire, more info can be queried with the ids of the text
        # Will allow for lazy loading data on client side down the line if needed on larger documents
        {status, texts} = LeafNode.Core.Text.list_texts(id)
        text_data = case status do
          :ok -> Enum.map(texts, fn item -> item.id end)
          _ -> []
        end
        doc_with_texts = Map.put(data, :texts, text_data)

        return(conn, 200, Helpers.http_resp(200, true, doc_with_texts))
      {:error, err} ->
        return(conn, 404, Helpers.http_resp(404, false, err))
    end
  end

  @doc """
    Update document by id
  """
  def update_document(conn, params) do
    case LeafNode.Core.Documents.edit_document(params) do
      {:ok, data} ->
        return(conn, 200, Helpers.http_resp(200, true, data))
      {:error, err} ->
        return(conn, 404, Helpers.http_resp(404, false, err))
    end
  end

 @doc """
    Create document
  """
  def create_document(conn, _params) do
    case LeafNode.Core.Documents.create_document() do
      {:ok, data} ->
        return(conn, 200, Helpers.http_resp(200, true, data))
      {:error, err} ->
        return(conn, 404, Helpers.http_resp(404, false, err))
    end
  end

 @doc """
    Delete document
  """
  def delete_document(conn, %{ "id" => id}) do
    case LeafNode.Core.Documents.delete_document(id) do
      {:ok, data} ->
        # attempt to delete associated texts (soft delete) - This needs som cases to make sure failures are logged
        {_, result} = LeafNode.Core.Text.list_texts(id)
        Enum.each(result, fn text ->
          LeafNode.Core.Text.edit_text(%{
            "id" => text.id,
            "is_deleted" => "true"
          })
        end)
        # TODO: keep texts as we use this for training later
        return(conn, 200, Helpers.http_resp(200, true, data))
      {:error, err} ->
        return(conn, 404, Helpers.http_resp(404, false, err))
    end
  end

 @doc """
    Execute document
  """
  def execute_document(conn, params) do
    id = Map.get(params, "id")
    payload = Map.drop(params, ["id"])
    # Start the server if not already running
    LeafNode.Servers.ExecutionServer.start_link(id)

    {status, %{ "document" => document, "results" => paragraph_execution_results}} =
      GenServer.call(String.to_atom("execution_process_" <> id), {:execute, id, payload})

    document_result = Map.get(document, :result)
    result = %{
      "document_result" => Map.get(paragraph_execution_results, document_result, document_result),
      "paragraph_results" => paragraph_execution_results
    }
    case status do
      :ok -> return(conn, 200, Helpers.http_resp(200, true, result))
      _ -> return(conn, 404, Helpers.http_resp(404, false, %{}))
    end
  end

  # JSON returned response helper method for the controller functions
  defp return(conn, status, data) do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Jason.encode!(data))
  end
end
