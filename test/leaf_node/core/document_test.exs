defmodule LeafNode.Core.DocumentTest do
  use LeafNodeWeb.ConnCase

  alias LeafNode.Structs.Document, as: Document
  alias LeafNode.Core.Dets, as: Dets

  @table_process :process_test
  @table_document :documents_test
  @process_payload %{
    "id" => "1111",
    "name" => "1111",
    "description" => "1111",
    "nodes" => [ "asd"]
  }

  def setup_tables_and_test_process do
    process_test_table = String.to_charlist("process_test.dets")
    document_test_table = String.to_charlist("document_test.dets")
    create_process_result = {:ok, "Successfully created process"}

    assert LeafNode.Core.Dets.open_table(@table_process, [{ :file, process_test_table }, { :type, :set }, {:auto_save, 60_000}]) === @table_process
    assert LeafNode.Core.Dets.open_table(@table_document, [{ :file, document_test_table }, { :type, :set }, {:auto_save, 60_000}]) === @table_document
    assert LeafNode.Core.Process.create_process(@process_payload, @table_process) === create_process_result
  end

  def generate_document(id, table \\ @table_document) do
    LeafNode.Core.Document.generate_document(id, table)
    Dets.insert(table, id, %Document{ id: id, description: "TODO" })
  end

  def delete_test_dets do
    File.rm("documents_test.dets")
    File.rm("process_test.dets")
  end

  test "generate_document - w_out/ OPEN_AI env" do
    setup_tables_and_test_process()

    {_status, resp} = LeafNode.Core.Process.list_processes(@table_process)
    id = Map.keys(resp) |> List.first

    assert generate_document(id) === :ok

    delete_test_dets()
  end

  test "edit_document" do
    setup_tables_and_test_process()

    {_status, resp} = LeafNode.Core.Process.list_processes(@table_process)
    id = Map.keys(resp) |> List.first

    # generate a document that will require updating
    generate_document(id)

    assert LeafNode.Core.Document.edit_document(id, %{ "description" => "This is a test update" }, @table_document) ===
      {:ok, "Successfully updated document"}

    delete_test_dets()
  end

  test "delete_document" do
    setup_tables_and_test_process()

    {_status, resp} =LeafNode.Core.Process.list_processes(@table_process)
    id = Map.keys(resp) |> List.first

    # generate a document that will require updating
    generate_document(id)

    assert LeafNode.Core.Document.delete_document(id, @table_document) ===
      {:ok, "Successfully removed document"}

    delete_test_dets()
  end

  test "list_documents" do
    setup_tables_and_test_process()

    {_status, resp} = LeafNode.Core.Process.list_processes(@table_process)
    id = Map.keys(resp) |> List.first

    # generate a document that will require updating
    generate_document(id)

    assert LeafNode.Core.Document.list_documents(@table_document) === {:ok, %{"1111" => %{description: "TODO", id: "1111"}}}

    delete_test_dets()
  end

  test "get_document" do
    setup_tables_and_test_process()

    {_status, resp} = LeafNode.Core.Process.list_processes(@table_process)
    id = Map.keys(resp) |> List.first

    # generate a document that will require updating
    generate_document(id)

    assert LeafNode.Core.Document.get_document(id, @table_document) === {:ok, %{description: "TODO", id: "1111"}}

    delete_test_dets()
  end
end
