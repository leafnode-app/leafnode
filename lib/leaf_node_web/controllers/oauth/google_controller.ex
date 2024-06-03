defmodule LeafNodeWeb.GoogleController do
  use LeafNodeWeb, :controller
  alias LeafNode.Google.OAuth, as: GoogleOAuth
  alias LeafNodeWeb.Router.Helpers, as: Routes
  import Logger

  @integration_type :google_sheet

  @doc """
    Request access url for the user to grant access to the scoped services
  """
  def request(conn, %{"node_id" => node_id} = params) do
    redirect_uri = Routes.google_url(conn, :callback)
    auth_url = GoogleOAuth.authorize_url(GoogleOAuth.client(), redirect_uri, %{ node_id: node_id})
    redirect(conn, external: auth_url)
  end

  @doc """
    Callback that takes the granted token after access grant to use to make a token request.
    If the user has a token already check expiry and maybe try generate a new one if needed
  """
  def callback(conn, %{"code" => code, "state" => state} = params) do
    state = Base.decode64!(state) |> Jason.decode!()
    user_id = conn.assigns.current_user.id

    %OAuth2.Client{ token: token_data} =
      GoogleOAuth.get_token(
        GoogleOAuth.client(),
        code,
        Routes.google_url(conn, :callback)
      )

      try do
      {_, value} = IntegrationsEnum.dump(@integration_type)
      # attempt to store token - the rescue will run if this fails for some reason
      LeafNode.Repo.OAuthToken.store_token(
        user_id,
        value,
        token_data.access_token,
        token_data.refresh_token,
        token_data.expires_at
      )

      # update the node integration settings flag - checks need to be done here so we know we update the flag
      {status, _node} = LeafNode.Repo.Node.edit_node(%{ "id" => state["node_id"], "integration_settings" => %{ "has_oauth" => true} })

      case status do
        :ok ->
          node_redirect(conn, state)
        _ ->
          Logger.error("Unable to  update the node oauth flag")
          node_redirect(conn, state)
      end
    rescue e ->
      Logger.error("There was a problem trying to store the token")
      node_redirect(conn, state)
    end
  end

  # redirect back to the dashboard board or to a node specific path
  defp node_redirect(conn, state), do: redirect(conn, to: "/dashboard/node/" <> state["node_id"])
end
