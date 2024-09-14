defmodule LeafNode.Repo.Agent do
  @moduledoc """
    Persistance and data query for Agents
  """
  require Logger
  alias LeafNode.Repo, as: LeafNodeRepo
  alias LeafNode.Schemas

  @doc """
    Create a agent - genreate an id and pass payload to be persisted
  """
  def create_agent(user_id) do
    # This generates a random email using a UUID for the agent
    email = UUID.uuid4() <> "@" <> config(:domain)
    changeset =
      Schemas.Agent.changeset(
        %Schemas.Agent{},
        %{
          user_id: user_id,
          # We can give the agent a name?
          # name: name,
          email: email,
          email_hash: email,
        }
      )

    case {_, result} = LeafNodeRepo.insert(changeset) do
      {:ok, _} ->
        agent_id = Map.get(result, :id)
        {:ok,
         %{
           id: agent_id
         }}

      {:error, _} ->
        {:error, "There was a problem creating agent"}
    end
  end

  @doc """
    Regenerate a email to get a new one for the user agent
  """
  def regenerate_email(user_id) do
    agent_data =
      try do
        struct = LeafNodeRepo.get_by!(Schemas.Agent, user_id: user_id)
        {:ok, struct}
      rescue
        _e ->
          {:error, "There was a problem trying to get the agent for user #{user_id}"}
      end

    IO.inspect(agent_data)
    case agent_data do
      {:ok, %Schemas.Agent{user_id: _user_id, id: id}} ->
        email = UUID.uuid4() <> "@" <> config(:domain)
        updat_agent = %{
          "id" => id,
          "email" => email,
          "email_hash" => email
        }

        edit_agent(updat_agent)

      _ ->
        {:error, "There was a problem trying to regenerate a agent email"}
    end
  end

  @doc """
    Edit a agent by id and the new details passed of the update we persist
  """
  def edit_agent(data) do
    result =
      try do
        struct = LeafNodeRepo.get!(Schemas.Agent, Map.get(data, "id", nil))
        {:ok, struct}
      rescue
        _e ->
          {:error, "There was an error trying to get the agent #{"id"}"}
      end

    # we have a struct that we got something
    case result do
      {:ok, struct} ->
        # here we try to delete the agent
        updated_struct =
          Ecto.Changeset.change(struct,
            email: Map.get(data, "email", struct.email),
            email_hash: Map.get(data, "email_hash", struct.email_hash)
          )

        # we need to add or update the agent texts here
        case LeafNodeRepo.update(updated_struct) do
          {:ok, _} ->
            {:ok, "Successfully updated agent"}

          {:error, _e} ->
            {:error, "There was a problem updating agent"}
        end

      _ ->
        {:error, "Unable to find agent"}
    end
  end

  @doc """
    Remove a agent by id
  """
  def delete_agent(id) do
    result =
      try do
        struct = LeafNodeRepo.get!(Schemas.Agent, id)
        {:ok, struct}
      rescue
        _e ->
          {:error, "There was an error trying to get the agent #{id}"}
      end

    case result do
      {:ok, struct} ->
        # here we try to delete the agent
        case LeafNodeRepo.delete(struct) do
          {:ok, _} -> {:ok, "Successfully deleted agent"}
          {:error, _} -> {:error, "There was a problem deleting agent"}
        end

      _ ->
        {:error, "Unable to find agent"}
    end
  end

  @doc """
    Get the details of a agent by user_id
  """
  def get_agent(user_id) do
    result =
      try do
        n = LeafNodeRepo.get_by!(Schemas.Agent, %{ user_id: user_id})

        {:ok,
         %{
           id: n.id,
           email: n.email,
           name: n.name,
           user_id: n.user_id
         }}
      rescue
        _e ->
          {:error, "There was an error trying to get the agent"}
      end

    case result do
      {:ok, data} -> {:ok, data}
      _ -> {:error, "There was an error getting the current agent"}
    end
  end

  defp config() do
    Application.get_env(:leaf_node, :node_mail, nil)
  end
  defp config(key) do
    config()[key]
  end

end
