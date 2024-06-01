defmodule LeafNodeWeb.GoogleController do
  use LeafNodeWeb, :controller
  alias LeafNode.GoogleOAuth
  alias LeafNodeWeb.Router.Helpers, as: Routes

  def request(conn, _params) do
    redirect_uri = Routes.google_url(conn, :callback)
    redirect(conn, external: GoogleOAuth.authorize_url(GoogleOAuth.client(), redirect_uri))
  end

  def callback(conn, %{"code" => code}) do
    client = GoogleOAuth.client()
    redirect_uri = Routes.google_url(conn, :callback)

    %OAuth2.Client{ token: token_data} = GoogleOAuth.get_token(client, code, redirect_uri)
    user_id = conn.assigns.current_user.id
    # TODO: use the changeset to determine if this needs to be success or not
    LeafNode.Repo.OAuthToken.store_token(user_id, "google_sheets", token_data.access_token, token_data.refresh_token, token_data.expires_at)

    text(conn, "Google Sheets integration successful!")
  end
end
