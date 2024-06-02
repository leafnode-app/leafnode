defmodule LeafNodeWeb.GoogleController do
  use LeafNodeWeb, :controller
  alias LeafNode.Google.OAuth, as: GoogleOAuth
  alias LeafNodeWeb.Router.Helpers, as: Routes

  @doc """
    Request access url for the user to grant access to the scoped services
  """
  def request(conn, _params) do
    redirect_uri = Routes.google_url(conn, :callback)
    redirect(conn, external: GoogleOAuth.authorize_url(GoogleOAuth.client(), redirect_uri))
  end

  @doc """
    Callback that takes the granted token after access grant to use to make a token request.
    If the user has a token already check expiry and maybe try generate a new one if needed
  """
  def callback(conn, %{"code" => code}) do
    user_id = conn.assigns.current_user.id

    client = GoogleOAuth.client()
    redirect_uri = Routes.google_url(conn, :callback)

    resp = GoogleOAuth.get_token(client, code, redirect_uri)
    %OAuth2.Client{ token: token_data} = resp

    # TODO: use the changeset to determine if this needs to be success or not
    LeafNode.Repo.OAuthToken.store_token(user_id, "google_sheets", token_data.access_token, token_data.refresh_token, token_data.expires_at)
    text(conn, "Google Sheets integration successful!")
  end
end
