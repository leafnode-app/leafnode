defmodule LeafNode.Repo.Expression do
  @moduledoc """
    Methods around the Expressions for the nodes and logic associated with them
  """
  import Ecto.Query, only: [from: 2]
  alias LeafNode.Repo, as: LeafNodeRepo
  alias LeafNode.Schemas

  @doc """
    Create an expression - generate an id and pass payload to be persisted
  """
  def create_expression(node_id, input, expression, type, value, enabled) do
    changeset = Schemas.Expression.changeset(%Schemas.Expression{},
      %{
        node_id: node_id,
        input: input,
        expression: expression,
        type: type,
        value: value,
        enabled: enabled,
      })

    case LeafNodeRepo.insert(changeset) do
      {:ok, result} ->
        {:ok,
         %{
           id: Map.get(result, :id)
         }}

      {:error, _} ->
        {:error, "There was a problem creating expression"}
    end
  end

  @doc """
    Edit an expression by id and the new details passed of the update we persist
  """
  def edit_expression(data) do
    result =
      try do
        struct = LeafNodeRepo.get!(Schemas.Expression, Map.get(data, "id", nil))
        {:ok, struct}
      rescue
        _e ->
          {:error, "There was an error trying to get the expression #{Map.get(data, "id")}"}
      end

    case result do
      {:ok, struct} ->
        updated_struct =
          Ecto.Changeset.change(struct,
            input: Map.get(data, "input", struct.input),
            expression: Map.get(data, "expression", struct.expression),
            type: Map.get(data, "type", struct.type),
            value: Map.get(data, "value", struct.value),
            enabled: Map.get(data, "enabled", struct.enabled),
          )

        case LeafNodeRepo.update(updated_struct) do
          {:ok, _} ->
            {:ok, "Successfully updated expression"}

          {:error, _e} ->
            {:error, "There was a problem updating expression"}
        end

      _ ->
        {:error, "Unable to find expression"}
    end
  end

  @doc """
    Remove an expression by id
  """
  def delete_expression(id) do
    result =
      try do
        struct = LeafNodeRepo.get!(Schemas.Expression, id)
        {:ok, struct}
      rescue
        _e ->
          {:error, "There was an error trying to get the expression #{id}"}
      end

    case result do
      {:ok, struct} ->
        case LeafNodeRepo.delete(struct) do
          {:ok, _} -> {:ok, "Successfully deleted expression"}
          {:error, _} -> {:error, "There was a problem deleting expression"}
        end

      _ ->
        {:error, "Unable to find expression"}
    end
  end

  @doc """
    Get the details of an expression by node_id
  """
  def get_expression_by_node(node_id) do
    result =
      try do
        expression =
          from(e in LeafNode.Schemas.Expression, where: e.node_id == ^node_id)
          |> LeafNodeRepo.one()

        case expression do
          nil -> {:error, "Expression not found for node ID #{node_id}"}
          n ->
            {:ok,
             %{
               id: n.id,
               node_id: n.node_id,
               input: n.input,
               expression: n.expression,
               type: n.type,
               value: n.value,
               enabled: n.enabled,
             }}
        end
      rescue
        _e ->
          {:error, "There was an error trying to get the expression #{node_id}"}
      end

    case result do
      {:ok, data} -> {:ok, data}
      _ -> {:error, "There was an error getting the current expression"}
    end
  end
end
