defmodule LeafNodeWeb.Plugs.UserAgentCheck do
  @moduledoc """
    Check if the email is relevant on the system
  """
  import Plug.Conn

  @doc """
    Initialize the conneciton with opts to be passed when passing the connection through the plug
  """
  def init(opts), do: opts

  @doc """
    The call function that gets called after init setup. We check the header and the access token
  """
  def call(%Plug.Conn{params: params} = conn, _opts) do
    # get agent to execute
    agent_email = params["To"]
    agent = LeafNode.Repo.get_by(LeafNode.Schemas.Agent, email_hash: agent_email)

    case agent do
      nil ->
        conn
        |> send_resp(403, "Forbidden")
        |> halt()
      _ ->
        conn
        |> put_private(:agent_id, agent.id)
        |> put_private(:user_id, agent.user_id)
    end
  end
end
