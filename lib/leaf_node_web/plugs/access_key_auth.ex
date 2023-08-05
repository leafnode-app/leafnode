defmodule LeafNodeWeb.Plugs.AccessKeyAuth do
  @moduledoc """
    Plug that will be used to check the connection against the access keys for a process to execute
  """
  import Plug.Conn
  alias LeafNode.Core.AccessKeys, as: AccessKeys

  @doc """
    Initialize the conneciton with opts to be passed when passing the connection through the plug
  """
  def init(opts), do: opts

  @doc """
    The call function that gets called after init setup. We check the header and the access token
  """
  def call(conn, _opts) do
    # we need to get the process that is being executed
    %{"process_id" => process_id} = Map.get(conn, :params, nil)

    if check_process_restriction(process_id) === :restricted do
      case get_req_header(conn, "authorization") do
        [token] ->
          token =
            String.split(token, " ")
            |> List.last()

          # we check if the process needs to be restricted
          check_process_access(conn, token, process_id)
        _ ->
          return( conn, 401,
            %{ "message" => "Unauthorized access execute restricted process.",
              "success" => false,
              "data" => %{}
            }
          )
      end
    else
      conn
    end
  end

  # we need to check if the process is restricted
  defp check_process_restriction(process_id) do
    {status, process} = LeafNode.Core.Process.get_process(process_id)
    case status do
      :ok ->
        if Map.get(process, :restricted, false) do
          :restricted
        else
          :non_restricted
        end
      _ -> :not_found
    end
  end

  # we check the passed tokena and if the access is relevant to process execution
  defp check_process_access(conn, token, process_id) do
    {status, valid_tokens} = AccessKeys.process_by_access_key
    case status do
      :ok ->
        access_token_processes = Map.get(valid_tokens, token, [])
        if Enum.member?(access_token_processes, process_id) do
          # we can assign a flag around the connection to know its accessible
          conn
           |> assign(:execution_access, true)
        else
          return( conn, 401,
            %{ "message" =>
                "Unauthorized access. Make sure the access token you have is correct",
              "success" => false,
              "data" => %{}
            }
          )
        end
      _ ->
        return( conn, 401,
          %{ "message" => "Unauthorized access.",
            "success" => false,
            "data" => %{}
          }
        )
    end
  end

  # JSON returned response helper method for the controller functions
  defp return(conn, status, data) do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Jason.encode!(data))
  end
end
