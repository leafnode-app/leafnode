defmodule LeafNode.Repo.Augmentation do
  @moduledoc """
    Methods around the Augmentation for the nodes and logic associated with them
  """
  import Ecto.Query, only: [from: 2]
  alias LeafNode.Repo, as: LeafNodeRepo
  alias LeafNode.Schemas

  @doc """
    Create an augmentation  for a given node
  """
  def create_augment(node_id, type, enabled, value, async) do
    changeset =
      Schemas.Augmentation.changeset(
        %Schemas.Augmentation{},
        %{
          node_id: node_id,
          type: type,
          value: value,
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
        {:error, "There was a problem creating augmentation"}
    end
  end

  @doc """
    Edit an augmentation by id
  """
  def edit_augment(data) do
    result =
      try do
        struct = LeafNodeRepo.get!(Schemas.Augmentation, Map.get(data, "id", nil))
        {:ok, struct}
      rescue
        _e ->
          {:error, "There was an error trying to get the augmentation #{Map.get(data, "id")}"}
      end

    case result do
      {:ok, struct} ->
        updated_struct =
          Ecto.Changeset.change(struct,
            type: Map.get(data, "type", struct.type),
            value: Map.get(data, "value", struct.value),
            enabled: Map.get(data, "enabled", struct.enabled),
            async: Map.get(data, "async", struct.async)
          )

        case LeafNodeRepo.update(updated_struct) do
          {:ok, _} ->
            {:ok, "Successfully updated augmentation"}

          {:error, _e} ->
            {:error, "There was a problem updating augmentation"}
        end

      _ ->
        {:error, "Unable to find augmentation"}
    end
  end

  @doc """
    Get the details of an augment by node_id
  """
  def get_augment_by_node(node_id) do
    result =
      try do
        augmentation =
          from(e in LeafNode.Schemas.Augmentation, where: e.node_id == ^node_id)
          |> LeafNodeRepo.one()

        case augmentation do
          nil ->
            {:error, "Augmentation not found for node ID #{node_id}"}

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
          {:error, "There was an error trying to get the augmentation #{node_id}"}
      end

    case result do
      {:ok, data} -> {:ok, data}
      _ -> {:error, "There was an error getting the current augmentation"}
    end
  end
end
