defmodule LeafNodeWeb.GoogleController do
  use LeafNodeWeb, :controller
  alias LeafNode.Google.OAuth, as: GoogleOAuth
  alias LeafNodeWeb.Router.Helpers, as: Routes

  @doc """
    Request access url for the user to grant access to the scoped services
  """
  def request(conn, %{"node_id" => node_id} = params) do
    redirect_uri = Routes.google_url(conn, :callback)
    # TOOD: change this so that its more generic as this is used for google as we pass the relevant node
    auth_url = GoogleOAuth.authorize_url(GoogleOAuth.client(), redirect_uri, %{ node_id: node_id})
    redirect(conn, external: auth_url)
  end

  @doc """
    Callback that takes the granted token after access grant to use to make a token request.
    If the user has a token already check expiry and maybe try generate a new one if needed
  """
  def callback(conn, %{"code" => code, "state" => state} = params) do
    # TOOD: we need to do some check around status?
    state = Base.decode64!(state) |> Jason.decode!()
    user_id = conn.assigns.current_user.id

    client = GoogleOAuth.client()
    redirect_uri = Routes.google_url(conn, :callback)

    resp = GoogleOAuth.get_token(client, code, redirect_uri)
    %OAuth2.Client{ token: token_data} = resp

    # TODO: use the changeset to determine if this needs to be success or not
    try do
      resp = LeafNode.Repo.OAuthToken.store_token(user_id, "google_sheets", token_data.access_token, token_data.refresh_token, token_data.expires_at)
      redirect(conn, to: "/dashboard/node/" <> state["node_id"])
    rescue e ->
      redirect(conn, to: "/dashboard/node/" <> state["node_id"])
    end
  end
end
