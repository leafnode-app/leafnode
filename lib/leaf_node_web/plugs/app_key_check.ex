defmodule LeafNodeWeb.Plugs.AppKeyCheck do
  @moduledoc """
  Check if the request coming in is using a valid app key
  """
  import Plug.Conn

  # General system messages
  @messages %{
    no_key: "No key found",
    invalid_key: "Invalid key",
    forbidden: "Forbidden",
    ok: "ok"
  }

  @doc """
  Initialize the plug
  """
  @spec init(Keyword.t()) :: Keyword.t()
  def init(opts), do: opts

  @doc """
  check if the key is sent and valid to be making requests to the server
  """
  @spec call(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t() | term()
  def call(conn, _opts) do
    case check_app_key(get_req_header(conn, "x-api-key")) do
      {:ok, _} ->
        conn
      {:error, _reason} ->
        conn
        |> send_resp(403, @messages.forbidden)
        |> halt()
    end
  end

  # check if the key is valid
  defp check_app_key(key) when key in [nil, "", []], do: {:error, @messages.no_key}
  defp check_app_key([key]) do
    if Application.get_env(:leaf_node, :app_key) === key do
      {:ok, @messages.ok}
    else
      {:error, @messages.invalid_key}
    end
  end
end
