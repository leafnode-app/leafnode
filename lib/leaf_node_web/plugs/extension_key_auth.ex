defmodule LeafNodeWeb.Plugs.ExtensionKeyAuth do
  @moduledoc """
    Check the call for the extension key used
  """
  import Plug.Conn

  @doc """
    Initialize the conneciton with opts to be passed when passing the connection through the plug
  """
  def init(opts), do: opts

  @doc """
    The call function that gets called after init setup. We check the header and the access token
  """
  def call(conn, _opts) do
    case get_req_header(conn, "x-extension-key") do
      [token] ->
        token =
          String.split(token, " ")
          |> List.last()

        check_token_validity(conn, token)

      _ ->
        return(conn, 401, %{
          "message" => "Probelem making a request",
          "success" => false,
          "data" => %{}
        })
    end
  end

  # we check the passed token validity
  defp check_token_validity(conn, extension_token) do
    token_resp = LeafNode.Repo.ExtensionToken.get_token_by_generated_id(extension_token)
    case token_resp do
      nil ->
        return(conn, 401, %{
          "message" => "Unauthorized access.",
          "success" => false,
          "data" => %{}
        })

      _ ->
        put_private(conn, :user_id, token_resp.user_id)
    end
  end

  # JSON returned response helper method for the controller functions
  defp return(conn, status, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(data))
  end
end
