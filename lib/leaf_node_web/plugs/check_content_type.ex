defmodule LeafNodeWeb.Plugs.CheckContentType do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _opts) do
    case get_req_header(conn, "content-type") do
      ["application/json" | _] ->
        conn

      _ ->
        conn
        |> put_status(:unsupported_media_type)
        |> return(400, %{
          "message" => "Unsupported Content-Type",
          "success" => false,
          "data" => %{}
        })
        |> halt()
    end
  end

  # JSON returned response helper method for the controller functions
  defp return(conn, status, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(data))
  end
end
