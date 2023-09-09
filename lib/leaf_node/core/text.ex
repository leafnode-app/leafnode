defmodule LeafNode.Core.Text do
  @moduledoc """
    Methods around the Text and persistence/data management
  """
  import Ecto.Query, only: [from: 2]
  alias LeafNode.Repo, as: LeafNodeRepo

  @doc """
    Create a text - genreate an id and pass payload to be persisted
  """
  def create_text(data) do
    # We need to get the data first if there is for the document and add order
    case LeafNode.Core.Documents.get_document(document_id = Map.get(data, "document_id")) do
      {:ok, _} ->
        count = case list_texts(document_id) do
          {:ok, texts} ->
            length(texts) + 1
          {:error, _} -> 1
        end

        add_count = Map.put_new(data, "order", count)
        changeset = LeafNodeWeb.Models.Text.changeset(%LeafNodeWeb.Models.Text{}, add_count)
        case LeafNodeRepo.insert(changeset) do
          {:ok, _} -> {:ok, "Successfully created text"}
          {:error, _} -> {:error, "There was a problem creating text"}
        end
      _ -> {:error, "Unable to find document"}
    end
  end

  @doc """
    Edit a text by id and the new details passed of the update we persist
  """
  def edit_text(data) do
    result = try do
      struct = LeafNodeRepo.get!(LeafNodeWeb.Models.Text, Map.get(data, "id", nil))
      {:ok, struct}
    rescue
      _e ->
        {:error, "There was an error trying to get the text"}
    end

    # we have a struct that we got something
    case result do
      {:ok, struct} ->
        # here we try to delete the document
        updated_struct = Ecto.Changeset.change(struct, [
          data: Map.get(data, "data", struct.data),
          document_id: Map.get(data, "document_id", struct.document_id),
          order: Map.get(data, "order", struct.order),
          # TODO: do we need to change reset the pseudo code on edit? UI can show the old code
          pseudo_code: Map.get(data, "pseudo_code", struct.pseudo_code),
          is_deleted: Map.get(data, "is_deleted", struct.is_deleted)
        ])
        # we need to add or update the document texts here
        case LeafNodeRepo.update(updated_struct) do
          {:ok, _} -> {:ok, "Successfully updated text"}
          {:error, _e} ->
            {:error, "There was a problem updating text"}
        end
      _ -> {:error, "Unable to find text"}
    end
  end

  @doc """
    Recmove a text by id
  """
  def delete_text(id) do
    result = try do
      struct = LeafNodeRepo.get!(LeafNodeWeb.Models.Text, id)
      {:ok, struct}
    rescue
      _e ->
        {:error, "There was an error trying to get the text #{id}"}
    end

    case result do
      {:ok, struct} ->
        # here we try to delete the document
        case LeafNodeRepo.delete(struct) do
          {:ok, _} -> {:ok, "Successfully deleted text"}
          {:error, _} -> {:error, "There was a problem deleting text"}
        end
      _ -> {:error, "Unable to find text"}
    end
  end

  @doc """
    List of all texts by document id
  """
  def list_texts(id) do
    query = from t in LeafNodeWeb.Models.Text,
      where: t.document_id == ^id,
      select: %{
        id: t.id,
        pseudo_code: t.pseudo_code,
        data: t.data,
        document_id: t.document_id,
        order: t.order,
    }

    if Kernel.length(LeafNodeRepo.all(query)) > 0 do
      {:ok, LeafNodeRepo.all(query)}
    else
      {:error, "There was an error getting the current texts"}
    end
  end

  @doc """
    Get the details of a text by its id
  """
  def get_text(id) do
    result = try do
      t = LeafNodeRepo.get!(LeafNodeWeb.Models.Text, id)
      {:ok, %{
        id: t.id,
        pseudo_code: t.pseudo_code,
        data: t.data,
        document_id: t.document_id
      }}
    rescue
      _e ->
        {:error, "There was an error trying to get the text #{id}"}
    end

    case result do
      {:ok, data} -> {:ok, data}
      _ -> {:error, "There was an error getting the current text"}
    end
  end

  @doc """
    Generate pseudo code for a text - attempt using GPT
  """
  def generate_code(id) do
    result = try do
      t = LeafNodeRepo.get!(LeafNodeWeb.Models.Text, id)
      {:ok, %{
        id: t.id,
        pseudo_code: t.pseudo_code,
        data: t.data,
        document_id: t.document_id
      }}
    rescue
      _e ->
        {:error, "There was an error trying to get the text #{id}"}
    end

    case result do
      {:ok, data} ->
        { status, resp } = LeafNode.Core.Gpt.prompt(Map.get(data, :data))
          case status do
            :ok -> edit_text(%{ "id" => data.id, "pseudo_code" => resp})
            _ -> {:error, "There was an error generating code"}
          end
      _ -> {:error, "There was an error getting the current text"}
    end
  end
end
