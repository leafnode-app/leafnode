defmodule LeafNode.Core.Documents do
  @moduledoc """
    Methods around the Documents and persistence/data management
  """
  alias LeafNode.Utils.Helpers
  alias LeafNode.Structs.Document, as: Document
  alias LeafNode.Structs.Paragraph, as: Paragraph
  alias LeafNode.Core.Dets, as: Dets

  # Config Table
  @table :documents

  @doc """
    Create a document - genreate an id and pass payload to be persisted
  """
  def create_document(data \\ %{}, table \\ @table, return_value \\ false) do
    id = UUID.uuid4()
    document =
      %Document{
        id: Map.get(data, :id, id),
        name: Map.get(data, :name, id),
        result: Map.get(data, :result, true),
        data: Map.get(data, :data, [%Paragraph{id: UUID.uuid4()}]),
      }

    result = Dets.insert(table, Map.get(data, "id", id), document)
    case result do
      :ok ->
        if return_value do
          {:ok, "Successfully created document", document}
        else
          {:ok, "Successfully created document"}
        end
      _ -> {:error, "There was an error creating document"}
    end
  end

  @doc """
    Edit a document by id and the new details passed of the update we persist
  """
  def edit_document(id, data \\ %{}, table \\ @table, return_value \\ false) do
    {status, document} = Dets.get_by_key(table, id)
    case status do
      :ok ->
        updated_document = %Document{
          id: document.id,
          name: Map.get(data, :name, document.name),
          result: Map.get(data, :result, document.result),
          data: Map.get(data, :data, document.data)
        }
        Dets.insert(table, id, updated_document)
        if return_value do
          {:ok, "Successfully updated document", updated_document}
        else
          {:ok, "Successfully updated document"}
        end
      _ -> {:error, "There was a problem editing the document"}
    end
  end

  @doc """
    Recmove a document by id
  """
  def delete_document(id, table \\ @table) do
    case Dets.delete(table, id) do
      :ok -> {:ok, "Successfully removed document"}
      _ -> {:error, "There was a problem removing document"}
    end
  end

  @doc """
    Return a list of all documents saved in the system
    Note: This is saved in DETS
  """
  def list_documents(table \\ @table) do
    { status, documents } = Dets.get_all(table)

    case status do
      :ok ->
        {:ok,
          Enum.map(documents,
            fn {_key, document} ->
              Map.from_struct(document)
            end
          )
          |> Helpers.list_to_map(%{}, :id)
        }
      _ -> {:error, "Unable to retrieve documents"}
    end
  end

  @doc """
    Get the details of a document by id
  """
  def get_document(id, table \\ @table) do
    {status, document} = Dets.get_by_key(table, id)

    case status do
      :ok -> {:ok, Map.from_struct(document)}
      _ -> {:error, "There was an error getting the current document"}
    end
  end
end
