defmodule LeafNode.Core.Documents do
  @moduledoc """
    Methods around the Documents and persistence/data management
  """
  import Ecto.Query, only: [from: 2]
  alias LeafNode.Repo, as: LeafNodeRepo

  @doc """
    Create a document - genreate an id and pass payload to be persisted
  """
  def create_document() do
    changeset = LeafNodeWeb.Models.Document.changeset(%LeafNodeWeb.Models.Document{result: "false"}, %{})

    case LeafNodeRepo.insert(changeset) do
      {:ok, _} -> {:ok, "Successfully created document"}
      {:error, _} -> {:error, "There was a problem creating document"}
    end
  end

  @doc """
    Edit a document by id and the new details passed of the update we persist
  """
  def edit_document(data) do
    result = try do
      struct = LeafNodeRepo.get!(LeafNodeWeb.Models.Document, Map.get(data, "id", nil))
      {:ok, struct}
    rescue
      _e ->
        {:error, "There was an error trying to get the document #{"id"}"}
    end

    # we have a struct that we got something
    case result do
      {:ok, struct} ->
        # here we try to delete the document
        updated_struct = Ecto.Changeset.change(struct, [
          name: Map.get(data, "name", struct.name),
          description: Map.get(data, "description", struct.description),
          result: Map.get(data, "result", struct.result),
        ])
        # we need to add or update the document texts here
        case LeafNodeRepo.update(updated_struct) do
          {:ok, _} -> {:ok, "Successfully updated document"}
          {:error, _e} ->
            {:error, "There was a problem updating document"}
        end
      _ -> {:error, "Unable to find document"}
    end
  end

  @doc """
    Recmove a document by id
  """
  def delete_document(id) do
    result = try do
      struct = LeafNodeRepo.get!(LeafNodeWeb.Models.Document, id)
      {:ok, struct}
    rescue
      _e ->
        {:error, "There was an error trying to get the document #{id}"}
    end

    case result do
      {:ok, struct} ->
        # here we try to delete the document
        case LeafNodeRepo.delete(struct) do
          {:ok, _} -> {:ok, "Successfully deleted document"}
          {:error, _} -> {:error, "There was a problem deleting document"}
        end
      _ -> {:error, "Unable to find document"}
    end
  end

  @doc """
    Return a list of all documents saved in the system
    Note: This is saved in DETS
  """
  def list_documents() do
    query = from d in LeafNodeWeb.Models.Document,
     select: %{
      id: d.id,
      name: d.name,
      description: d.description,
      result: d.result
    }

    if Kernel.length(LeafNodeRepo.all(query)) > 0 do
      {:ok, LeafNodeRepo.all(query)}
    else
      {:error, "There was an error getting the current document"}
    end
  end

  @doc """
    Get the details of a document by id
  """
  def get_document(id) do
    result = try do
      d = LeafNodeRepo.get!(LeafNodeWeb.Models.Document, id)
      {:ok, %{
        id: d.id,
        name: d.name,
        description: d.description,
        result: d.result
      }}
    rescue
      _e ->
        {:error, "There was an error trying to get the document #{id}"}
    end

    case result do
      {:ok, data} -> {:ok, data}
      _ -> {:error, "There was an error getting the current document"}
    end
  end
end
