defmodule LeafNode.Repo.InputProcess do
  @moduledoc """
    Methods around the InputProcess for the nodes and logic associated with them
  """
  import Ecto.Query, only: [from: 2]
  alias LeafNode.Repo, as: LeafNodeRepo
  alias LeafNode.Schemas

  @doc """
    Create an Input Process  for a given node
  """
  def create_input_process(node_id, type, enabled, value, async) do
    changeset =
      Schemas.InputProcess.changeset(
        %Schemas.InputProcess{},
        %{
          node_id: node_id,
          type: type,
          type_hash: type,
          value: value,
          value_hash: value,
          enabled: enabled,
          async: async
        }
      )

    case LeafNodeRepo.insert(changeset) do
      {:ok, result} ->
        {:ok,
         %{
           id: Map.get(result, :id)
         }}

      {:error, _} ->
        {:error, "There was a problem creating input process"}
    end
  end

  @doc """
    Edit an input process by id
  """
  def edit_input_process(data) do
    result =
      try do
        struct = LeafNodeRepo.get!(Schemas.InputProcess, Map.get(data, "id", nil))
        {:ok, struct}
      rescue
        _e ->
          {:error, "There was an error trying to get the InputProcess #{Map.get(data, "id")}"}
      end

    case result do
      {:ok, struct} ->
        updated_struct =
          Ecto.Changeset.change(struct,
            type: Map.get(data, "type", struct.type),
            type_hash: Map.get(data, "type", struct.type),
            value: Map.get(data, "value", struct.value),
            value_hash: Map.get(data, "value", struct.value),
            enabled: Map.get(data, "enabled", struct.enabled),
            async: Map.get(data, "async", struct.async)
          )

        case LeafNodeRepo.update(updated_struct) do
          {:ok, _} ->
            {:ok, "Successfully updated InputProcess"}

          {:error, _e} ->
            {:error, "There was a problem updating InputProcess"}
        end

      _ ->
        {:error, "Unable to find InputProcess"}
    end
  end

  @doc """
    Get the details of an input_process by node_id
  """
  def get_input_process_by_node(node_id) do
    result =
      try do
        input_process =
          from(e in LeafNode.Schemas.InputProcess, where: e.node_id == ^node_id)
          |> LeafNodeRepo.one()

        case input_process do
          nil ->
            {:error, "InputProcess not found for node ID #{node_id}"}

          n ->
            {:ok,
             %{
               id: n.id,
               node_id: n.node_id,
               type: n.type,
               value: n.value,
               enabled: n.enabled,
               async: n.async
             }}
        end
      rescue
        _e ->
          {:error, "There was an error trying to get the InputProcess #{node_id}"}
      end

    case result do
      {:ok, data} -> {:ok, data}
      _ -> {:error, "There was an error getting the current InputProcess"}
    end
  end
end
