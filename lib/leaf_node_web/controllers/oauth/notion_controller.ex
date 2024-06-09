defmodule LeafNodeWeb.NotionController do
  @moduledoc """
    The OAuth controller that will manage the redirects and reqeuest to for token in order to set or store for the user
  """
  use LeafNodeWeb, :controller
  alias LeafNode.Notion.OAuth, as: NotionOAuth
  alias LeafNodeWeb.Router.Helpers, as: Routes
  require Logger

  # TODO: this is too hard coded, later we might request other things from notion
  @integration_type :notion
  @doc """
    Request access url for the user to grant access to the scoped services
  """
  def request(conn, %{"node_id" => node_id}) do
    redirect_uri = Routes.notion_url(conn, :callback)
    auth_url = NotionOAuth.authorize_url(NotionOAuth.client(), redirect_uri, %{ node_id: node_id})
    redirect(conn, external: auth_url)
  end

  @doc """
    Callback that takes the granted token after access grant to use to make a token request.
    If the user has a token already check expiry and maybe try generate a new one if needed
  """
  # TODO: this is an error case we might need to look into managing
  def callback(conn, %{ "error" => error, "state" => state}) do
    state = Base.decode64!(state) |> Jason.decode!()
    Logger.error(error)
    node_redirect(conn, state)
  end
  def callback(conn, %{"code" => code, "state" => state}) do
    state = Base.decode64!(state) |> Jason.decode!()
    user_id = conn.assigns.current_user.id

    # Here we are not passing the client, we should look at making this generic so we can pass and joining the two?
    {status, resp} =
      NotionOAuth.get_token(
        code,
        Routes.notion_url(conn, :callback)
      )

    if status === :ok do
      try do
        {_, value} = IntegrationsEnum.dump(@integration_type)
        # attempt to store token - the rescue will run if this fails for some reason
        LeafNode.Repo.OAuthToken.store_token(
          user_id,
          value,
          resp["access_token"]
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
    else
      Logger.error("Problem getting the access key")
      node_redirect(conn, state)
    end

  end

  # redirect back to the dashboard board or to a node specific path
  defp node_redirect(conn, state), do: redirect(conn, to: "/dashboard/node/" <> state["node_id"])
end
