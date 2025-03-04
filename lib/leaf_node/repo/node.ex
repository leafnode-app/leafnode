defmodule LeafNode.Repo.Node do
  @moduledoc """
    Methods around the Documents and persistence/data management
  """

  # TODO: add limit for nodes based off user account - dont delete, just prevent adding

  import Ecto.Query, only: [from: 2]
  require Logger
  alias LeafNode.Repo, as: LeafNodeRepo
  alias LeafNode.Schemas

  @integration_list ["none" , "notion_page_read"]

  @doc """
    Create a node - genreate an id and pass payload to be persisted
  """
  def create_node(user_id) do
    access_key = UUID.uuid4()
    # This generates a random email using a UUID for the node
    email = UUID.uuid4() <> "@" <> config(:domain)
    changeset =
      Schemas.Node.changeset(
        %Schemas.Node{},
        %{
          user_id: user_id,
          access_key: access_key,
          access_key_hash: access_key,
          integration_settings: %{type: "none", input: nil, has_oauth: false},
          email: email,
          email_hash: email,
        }
      )
    # TODO: Use the flag to check if valid
    Logger.debug(changeset, label: "create_node changeset")

    case {_, result} = LeafNodeRepo.insert(changeset) do
      {:ok, _} ->
        node_id = Map.get(result, :id)
        # attempt to make an init node expression - we rely on the schema to set defaults
        # A sync, we dont need it it but it can be set as well
        Task.start(fn ->
          LeafNode.Repo.Expression.create_expression(node_id, "", "===", "string", "", false)
          LeafNode.Repo.InputProcess.create_input_process(node_id, "ai", "", true, true)
        end)

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

    integrations_settings = if is_nil(data["integration_settings"]), do: %{}, else: data["integration_settings"]
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
            expected_payload: Map.get(data, "expected_payload", struct.expected_payload),
            integration_settings:
              Map.merge(struct.integration_settings, integrations_settings)
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
          access_key: n.access_key,
          integration_settings: n.integration_settings
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
           access_key: n.access_key,
           email: n.email,
           integration_settings: n.integration_settings,
           user_id: n.user_id
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

  # The expression and condition types options - this can be a def of a struct later
  def expression_types do
    ExpressionsEnum.__enum_map__()
    |> Enum.map(fn {_, v} -> v end)
  end

  def condition_types do
    CondEnum.__enum_map__()
    |> Enum.map(fn {_, v} -> v end)
  end

  # This expands the enum and returns a list
  # potentially create a type and mapped to integration key
  def integration_types do
    IntegrationsEnum.__enum_map__()
    |> Enum.map(fn {_, v} -> v end)
  end

  def integrations_list do
    IntegrationsEnum.__enum_map__()
    |> Enum.map(fn {_, v} -> v end)

    Enum.map(@integration_list, fn item ->
      i_type = Enum.at(String.split(item, "_"), 0)
      {item, i_type}
    end)
  end

  defp config() do
    Application.get_env(:leaf_node, :node_mail, nil)
  end
  defp config(key) do
    config()[key]
  end

end
