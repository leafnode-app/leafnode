defmodule LeafNodeWeb.Api.DocumentController do
  @moduledoc """
    Controller that interfaces with the clients request and all the helpers around the processes
  """
  use LeafNodeWeb, :controller

  import Plug.Conn
  alias LeafNode.Utils.Helpers, as: Helpers
  alias LeafNode.Execute.Process, as: Execute
  alias LeafNode.Core.Process, as: Process


  # The swagger tags
  @tags ["Processes"]

  # Constants
  @id "process_id"
  @output "output"

  # response codes
  @success_code 200
  @error_code 400

  @doc """
    Get all processes
  """
  def get_processes(conn, _params) do
    {status, resp} = Process.list_processes()
    case status do
      :ok ->
        result = Enum.map(resp, fn {key, _value} -> key end)
        return(conn, @success_code, Helpers.http_resp(@success_code, true, result))
      _ -> return(conn, @error_code, Helpers.http_resp(@error_code, false, resp))
    end
  end

  @doc """
    Get all processes by id and return the response to the requester if exists or a relevant error response
  """
  def get_process(conn, params) do
    {status, resp} = Process.get_process(Map.get(params, @id, nil))
    case status do
      :ok ->
        return(conn, @success_code, Helpers.http_resp(@success_code, true, resp))
      _ ->
        return(conn, @error_code, Helpers.http_resp(@error_code, false, %{}))
    end
  end

  @doc """
    Execute a given process with a payload and only returns entire execution output
  """
  def execute(conn, params) do
    { status, exec_resp } = init_execution_data(params, Map.get(conn.assigns, :execution_access, false))
    status = if status === :error, do:  400, else: 200
    result_flag = if status === 200, do: true, else: false
    return(conn, status,
      Helpers.http_resp(status, result_flag, Map.get(exec_resp, @output)))
  end

  @doc """
    Executes but returns the logs of all child nodes that ran and their results through process execution
  """
  def execute_verbose(conn, params) do
    { status, exec_resp } = init_execution_data(params, true)
    status = if status === :error, do:  400, else: 200
    result_flag = if status ===  200, do: true, else: false
    return(conn, status,
      Helpers.http_resp(status, result_flag, exec_resp))
  end

  @doc """
    Create a new process - The entry point that will create a new one with passed details
  """
  # Generates id and we need to pass the entire object if we want create
  # We add an entry node to the application by default
  # entry node needs to be added from the client
  def create(conn, params) do
    {status, resp} = Process.create_process(params)
    case status do
      :ok -> return(conn, @success_code, Helpers.http_resp(@success_code, true, resp))
      _ -> return(conn, @error_code, Helpers.http_resp(@error_code, false, resp))
    end
  end

  @doc """
    Delete or remove a process from the system
  """
  def delete(conn, params) do
    {status, resp} = Process.delete_process(Map.get(params, @id, nil))
    case status do
      :ok -> return(conn, @success_code, Helpers.http_resp(@success_code, true, resp))
      _ -> return(conn, @error_code, Helpers.http_resp(@error_code, false, resp))
    end
  end

  @doc """
    Update a process by id - Note this takes the entire process to update
  """
  def update(conn, params) do
    data = Map.drop(params, [@id])
    {status, resp} = Process.edit_process(Map.get(params, @id, nil), data)

    case status do
      :ok -> return(conn, @success_code, Helpers.http_resp(@success_code, true, resp))
      _ -> return(conn, @error_code, Helpers.http_resp(@error_code, false, resp))
    end
  end

  # Prepare initial data and payload to be passed to be executed if relevant
  defp init_execution_data(params, bypass) do
    process_id = Map.get(params, @id)
    payload = Map.drop(params, [@id])
    Execute.init_execute_process(process_id, payload, bypass)
  end

  # JSON returned response helper method for the controller functions
  defp return(conn, status, data) do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Jason.encode!(data))
  end
end
