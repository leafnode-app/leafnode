defmodule LeafNode.Core.Node do
  @moduledoc """
    Methods around the Documents and persistence/data management
  """
  import Ecto.Query, only: [from: 2]
  alias LeafNode.Repo, as: LeafNodeRepo
  alias LeafNode.Schemas

  @doc """
    Create a node - genreate an id and pass payload to be persisted
  """
  def create_node(user_id) do
    changeset = Schemas.Node.changeset(%Schemas.Node{}, %{user_id: user_id, access_key: UUID.uuid4()})

    case {_, result} = LeafNodeRepo.insert(changeset) do
      {:ok, _} ->
        node_id = Map.get(result, :id)

        # attempt to make an init node expression - we rely on the schema to set defaults
        LeafNode.Core.Expression.create_expression(node_id, "some.object.key", "===", "string", "")

        {:ok,
         %{
           id: node_id
         }}

      {:error, _} ->
        {:error, "There was a problem creating node"}
    end
  end

  @doc """
    Edit a node by id and the new details passed of the update we persist
  """
  def edit_node(data) do
    result =
      try do
        struct = LeafNodeRepo.get!(Schemas.Node, Map.get(data, "id", nil))
        {:ok, struct}
      rescue
        _e ->
          {:error, "There was an error trying to get the node #{"id"}"}
      end

    # we have a struct that we got something
    case result do
      {:ok, struct} ->
        # here we try to delete the node
        updated_struct =
          Ecto.Changeset.change(struct,
            title: Map.get(data, "title", struct.title),
            description: Map.get(data, "description", struct.description),
            enabled: Map.get(data, "enabled", struct.enabled),
            should_log: Map.get(data, "should_log", struct.should_log),
            expected_payload: Map.get(data, "expected_payload", struct.expected_payload)
          )

        # we need to add or update the node texts here
        case LeafNodeRepo.update(updated_struct) do
          {:ok, _} ->
            {:ok, "Successfully updated node"}

          {:error, _e} ->
            {:error, "There was a problem updating node"}
        end

      _ ->
        {:error, "Unable to find node"}
    end
  end

  @doc """
    Remove a node by id
  """
  def delete_node(id) do
    result =
      try do
        struct = LeafNodeRepo.get!(Schemas.Node, id)
        {:ok, struct}
      rescue
        _e ->
          {:error, "There was an error trying to get the node #{id}"}
      end

    case result do
      {:ok, struct} ->
        # here we try to delete the node
        case LeafNodeRepo.delete(struct) do
          {:ok, _} -> {:ok, "Successfully deleted node"}
          {:error, _} -> {:error, "There was a problem deleting node"}
        end

      _ ->
        {:error, "Unable to find node"}
    end
  end

  @doc """
    Return a list of all documents saved in the system
    Note: This is saved in DETS
  """
  def list_nodes(user_id) do
    query =
      from(n in Schemas.Node,
        where: n.user_id == ^user_id,
        select: %{
          id: n.id,
          title: n.title,
          description: n.description,
          enabled: n.enabled,
          should_log: n.should_log,
          expected_payload: n.expected_payload,
          access_key: n.access_key
        }
      )

    if Kernel.length(LeafNodeRepo.all(query)) > 0 do
      {:ok, LeafNodeRepo.all(query)}
    else
      {:error, "There was an error getting the current node"}
    end
  end

  @doc """
    Get the details of a node by id
  """
  def get_node(id) do
    IO.inspect(id, label: "GETTING NODE")
    result =
      try do
        n = LeafNodeRepo.get!(Schemas.Node, id)

        {:ok,
         %{
           id: n.id,
           title: n.title,
           description: n.description,
           enabled: n.enabled,
           should_log: n.should_log,
           expected_payload: n.expected_payload,
           access_key: n.access_key
         }}
      rescue
        _e ->
          {:error, "There was an error trying to get the node #{id}"}
      end

    case result do
      {:ok, data} -> {:ok, data}
      _ -> {:error, "There was an error getting the current node"}
    end
  end
end
