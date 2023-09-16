defmodule LeafNodeWeb.Web.Live.Documents do
  use LeafNodeWeb, :live_view

  # Render function
  def render(assigns) do
    # TODO: We need to move the layout to accept props
    ~H"""
      <!-- Header -->
      <div class="flex justify-between items-center mb-4">
        <h1 class="text-2xl font-semibold mb-1">Documents</h1>
        <!-- Primary Button -->
        <button
          phx-click="document_create"
          class="bg-blue-700 hover:bg-blue-600 py-2 px-4 text-sm rounded transition duration-200 ease-in-out">
          Create
        </button>
      </div>
      <%= if is_nil(@documents) or Kernel.length(@documents) < 1 do %>
        <p> There are no documents, create a new one to get started</p>
      <% else %>
        <ul class="space-y-4">
          <%= for document <- @documents do %>
            <li>
              <a class="block bg-gray-700 hover:bg-gray-600 transition duration-200 ease-in-out p-4 rounded-lg">
                <div class="flex justify-between items-center">
                  <div>
                    <h2 class="text-lg font-semibold text-white">
                      <%= document.name %>
                    </h2>
                    <p class="text-gray-400">
                      <%= document.description %>
                    </p>
                    <p class="text-gray-400 text-sm">
                      <%= document.id %>
                    </p>
                  </div>
                  <div class="space-x-2">
                    <!-- Primary Button -->
                    <button phx-click="document_edit" phx-value-id={document.id} class="bg-blue-700 hover:bg-blue-600 text-white py-1 px-3 rounded text-sm transition duration-200 ease-in-out">
                      Edit
                    </button>
                    <!-- Destructive Button -->
                    <button phx-click="document_delete" phx-value-id={document.id} class="bg-red-700 hover:bg-red-600 text-white py-1 px-3 rounded text-sm transition duration-200 ease-in-out">
                      Delete
                    </button>
                  </div>
                </div>
              </a>
            </li>
          <% end %>
        </ul>
      <% end %>
    """
  end

  @doc """
    Init func that is run on init of the view
  """
  def mount(_params, _session, socket) do
    # TODO: Check if the socket is ready before we do anything here
    # get the new list that we send off
    {:ok, assign(socket, :documents, get_documents())}
  end

  @doc """
    The events to manage the creation of documents
  """
  def handle_event("document_create", _unsigned_params, socket) do
    socket = case LeafNode.Core.Documents.create_document() do
      {:ok, data} ->
        socket = put_flash(socket, :info, "Successfully created document")
        redirect(socket, to: "/document/#{data.id}")
      {:error, _err} ->
        socket
    end

    {:noreply, socket}
  end

  def handle_event("document_edit", %{ "id" => id, "value" => _}, socket) do
    socket = push_navigate(socket, to: "/document/#{id}")
    {:noreply, socket}
  end

  def handle_event("document_delete", %{ "id" => id, "value" => _}, socket) do
    documents = case LeafNode.Core.Documents.delete_document(id) do
      {:ok, _data} ->
        # attempt to delete associated texts (soft delete) - This needs som cases to make sure failures are logged
        {status, result} = LeafNode.Core.Text.list_texts(id)

        case status do
          :ok ->
            Enum.each(result, fn text ->
              LeafNode.Core.Text.edit_text(%{
                "id" => text.id,
                "is_deleted" => "true"
              })
            end)
          _ -> IO.inspect("No texts to remove for the current document")
        end
        # TODO: keep texts as we use this for training later

        # get the new list that we send off
        get_documents()
      {:error, err} ->
        err
    end

    socket = put_flash(socket, :info, "Successfully remvoved document")
    socket = assign(socket, :documents, documents)
    {:noreply, socket}
  end

  # helper functions to manage the reuse of certain calls
  defp get_documents() do
    case LeafNode.Core.Documents.list_documents do
      {:ok, data} ->
        data
      {:error, _err} ->
        IO.inspect("There was an error getting the documents")
        []
    end
  end
end
