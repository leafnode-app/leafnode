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
    {status, resp} = GenServer.call(LeafNode.Servers.MemoryServer, :get_all_documents)

    case status do
      :ok ->
        result =
          Enum.map(resp, fn {key, _val} -> key end)

        return(conn, 200, Helpers.http_resp(200, true, result))
      _ -> return(conn, 404, Helpers.http_resp(404, false, %{}))
    end
  end

  @doc """
    Get all documents
  """
  def get_documents(conn, _params) do
    {status, resp} = GenServer.call(LeafNode.Servers.MemoryServer, :get_all_documents)

    case status do
      :ok -> return(conn, 200, Helpers.http_resp(200, true, resp))
      _ -> return(conn, 404, Helpers.http_resp(404, false, %{}))
    end
  end

  @doc """
    Get document by id
  """
  def get_document_by_id(conn, %{ "id" => id}) do
    {status, resp} = GenServer.call(LeafNode.Servers.MemoryServer, {:get_document, id})
    case status do
      :ok -> return(conn, 200, Helpers.http_resp(200, true, resp))
      _ -> return(conn, 404, Helpers.http_resp(404, false, %{}))
    end
  end

  @spec update_document(Plug.Conn.t(), map) :: Plug.Conn.t()
  @doc """
    Update document by id
  """
  def update_document(conn, params) do
    data = Enum.into(params, %{}, fn {k, v} ->
      {String.to_atom(k), v}
    end)
    # raise "error"
    data_count = length(Map.get(params, "data", []))
    {status, resp} =
      GenServer.call(LeafNode.Servers.DiskServer, {:update_document, data.id, data}, data_count * 5000)
    case status do
      :ok -> return(conn, 200, Helpers.http_resp(200, true, resp))
      _ -> return(conn, 404, Helpers.http_resp(404, false, %{}))
    end
  end

 @doc """
    Create document
  """
  def create_document(conn, _params) do
    # TODO: we need to create before adding, cant create with data, generated data only
    {status, resp} = GenServer.call(LeafNode.Servers.DiskServer, :create_document)
    case status do
      :ok ->
        return(conn, 200, Helpers.http_resp(200, true, resp))
      _ -> return(conn, 404, Helpers.http_resp(404, false, %{}))
    end
  end

 @doc """
    Delete document
  """
  def delete_document(conn, params) do
    {status, resp} = GenServer.call(LeafNode.Servers.DiskServer, {:delete_document, Map.get(params, "id")})
    case status do
      :ok -> return(conn, 200, Helpers.http_resp(200, true, resp))
      _ -> return(conn, 404, Helpers.http_resp(404, false, %{}))
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
