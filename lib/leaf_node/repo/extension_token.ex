defmodule LeafNode.Repo.ExtensionToken do
  alias LeafNode.Repo.ExtensionToken
  alias LeafNode.Repo
  alias LeafNode.Schemas.ExtensionToken

  @doc """
    Store and generate a token for the user to have and use
  """
  def generate_token(user_id, token) do
    changeset = %ExtensionToken{}
    |> ExtensionToken.changeset(%{
      user_id: user_id,
      token: token
    })

    Repo.insert!(changeset)
  end

  @doc """
    Regenerate a token to get a new one made
  """
  def regenerate_token(id) do
    token_data = try do
      struct = get_token(id)
      {:ok, struct}
    rescue
      _e ->
        {:error, "There was an error trying to get the extension token #{id}"}
    end

    case token_data do
      {:ok, %LeafNode.Schemas.ExtensionToken{user_id: user_id, id: id}} ->
        update_token = %{
          "id" => id,
          "token" => UUID.uuid4(),
          "user_id" => user_id
        }

        updated_token = edit_token(update_token)
        {:ok, updated_token}
      _ ->
        {:error, "There was a problem trying to regenerate a token"}
    end
  end

  @doc """
    Update the extension token in order to make a new token and replace current
  """
  def edit_token(data) do
    result =
      try do
        struct = Repo.get!(ExtensionToken, Map.get(data, "id", nil))
        {:ok, struct}
      rescue
        _e ->
          {:error, "There was an error trying to get the extension token #{Map.get(data, "id")}"}
      end

    case result do
      {:ok, struct} ->
        updated_struct =
          Ecto.Changeset.change(struct,
            user_id: Map.get(data, "user_id", struct.user_id),
            token: Map.get(data, "token", struct.token)
          )

        case Repo.update(updated_struct) do
          {:ok, _} ->
            {:ok, "Successfully updated extension token"}

          {:error, _e} ->
            {:error, "There was a problem updating extension token"}
        end

      _ ->
        {:error, "Unable to find extension token"}
    end
  end

  @doc """
    Fetch the extension token by id
  """
  def get_token(id) do
    Repo.get(ExtensionToken,id)
  end

  @doc """
    Fetch the extension token by user id
  """
  def get_token_by_user(user_id) do
    Repo.get_by(ExtensionToken, user_id: user_id)
  end
end
