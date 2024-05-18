defmodule LeafNode.Core.Log do
  @moduledoc """
    Methods around the Log and persistence/data management
  """
  import Ecto.Query, only: [from: 2, where: 3, preload: 2]
  alias LeafNode.Repo, as: LeafNodeRepo
  alias LeafNode.Schemas

  @doc """
    Create a log - genreate an id and pass payload to be persisted
  """
  def create_log(node_id, input, result, status) do
    changeset =
      Schemas.Log.changeset(%Schemas.Log{}, %{
        node_id: node_id,
        input: input,
        result: result,
        status: status
      })

    case {_, result} = LeafNodeRepo.insert(changeset) do
      {:ok, _} ->
        {:ok,
         %{
           id: Map.get(result, :id)
         }}

      {:error, _} ->
        {:error, "There was a problem creating log"}
    end
  end

  @doc """
    Return a list of all documents saved in the system
    Note: This is saved in DETS
  """
  def list_logs(node_id) do
    query =
      from(n in Schemas.Log,
        where: n.node_id == ^node_id,
        select: %{
          id: n.id,
          node_id: n.node_id,
          input: n.input,
          result: n.result,
          status: n.status,
          inserted_at: n.inserted_at,
          updated_at: n.updated_at,
        }
      )

    if Kernel.length(LeafNodeRepo.all(query)) > 0 do
      {:ok, LeafNodeRepo.all(query)}
    else
      {:error, "There was an error getting the current log"}
    end
  end

  @doc """
    Get the details of a log by id
  """
  def get_log(node_id) do
    result =
      try do
        n = LeafNodeRepo.get!(Schemas.Log, node_id)

        {:ok,
         %{
           id: n.id,
           node_id: n.node_id,
           input: n.input,
           result: n.result,
           status: n.status,
           inserted_at: n.inserted_at,
           updated_at: n.updated_at,
         }}
      rescue
        _e ->
          {:error, "There was an error trying to get the log #{node_id}"}
      end

    case result do
      {:ok, data} -> {:ok, data}
      _ -> {:error, "There was an error getting the current log"}
    end
  end

  @doc """
    Get the associated node for the current log
  """
  def get_log_with_node(log_id) do
    Schemas.Log
    |> where([l], l.id == ^log_id)
    |> preload(:node)
    |> LeafNodeRepo.one()
  end
end
