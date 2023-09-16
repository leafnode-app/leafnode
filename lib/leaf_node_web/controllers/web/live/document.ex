defmodule LeafNodeWeb.Web.Live.Document do
  use LeafNodeWeb, :live_view

  # Render function
  def render(assigns) do
    # TODO: We need to move the layout to accept props
    ~H"""
      <!-- Header -->
      <div class="mb-4">
        <h1 class="text-2xl font-semibold mb-1"><%= @document.name %></h1>
        <h6 class="text-lg text-gray-400"><%= @document.description %></h6>
        <h6 class="text-sm text-gray-400"><%= @document.id %></h6>
        <h6 class="text-sm text-gray-400">Document result: <%= @document.result %></h6>
        <div class="mt-5">
          <!-- Primary Button -->
          <button
            phx-click="document_execute"
            class="bg-blue-700 hover:bg-blue-600 py-2 px-4 text-sm rounded transition duration-200 ease-in-out">
            Execute
          </button>
          <!-- Secondary Button -->
          <button
            phx-click="document_settings"
            class="bg-gray-700 hover:bg-gray-600 py-2 px-4 text-sm rounded transition duration-200 ease-in-out">
            Edit Settings
          </button>
        </div>
      </div>

      <!-- Vertical Timeline -->
      <div class="relative">
        <div class="absolute top-0 h-full w-0.5 bg-gray-500"></div>
        <ul class="space-y-4">
          <%= for text_block <- @texts do %>
            <li class="bg-gray-700 p-4 ml-5 rounded-lg flex">
              <div class="rounded-full bg-gray-500 h-6 w-6 mt-2"></div>
              <div class="flex-1 ml-4">
                <div class="flex justify-between">
                  <div class="text-gray-400 text-xs mb-2"><%= text_block.id %> </div>
                  <input value="test" type="checkbox" class="form-checkbox h-4 w-4 text-blue-600">
                </div>
                <form id={"form-#{text_block.id}"}>
                  <input
                    phx-debounce="200"
                    phx-change="update_text_block"
                    phx-value-id={text_block.id}
                    name={"content-#{text_block.id}"}
                    class="bg-gray-600 rounded p-2 w-full text-white outline-none"
                    value={text_block.data || ""}
                    placeholder="Express notes here"
                  />
                </form>
                <div class="flex justify-end space-x-2 mt-2">
                  <!-- Secondary Button -->
                  <button
                    phx-click="generate_text_code"
                    phx-value-id={text_block.id}
                    class="bg-gray-600 hover:bg-gray-500 text-white py-1 px-3 rounded text-sm transition duration-200 ease-in-out">
                    Generate Code
                  </button>
                  <!-- Destructive Button -->
                  <button
                    phx-click="delete_text_block"
                    phx-value-id={text_block.id}
                    class="bg-red-700 hover:bg-red-600 text-white py-1 px-3 rounded text-sm transition duration-200 ease-in-out">
                    Delete
                  </button>
                </div>
                <%= if !is_nil(text_block.pseudo_code) do%>
                  <div class="bg-gray-800 p-2 rounded mt-5">
                    <!-- Pseudo Code -->
                    <pre class="text-gray-300 text-sm"><%= text_block.pseudo_code %></pre>
                  </div>
                <% end %>
              </div>
            </li>
          <% end %>
          <!-- Add New Timeline Item -->
          <li class="flex items-start space-x-4 ml-5">
            <div class="rounded-full bg-gray-500 h-6 w-6 mt-1.5"></div>
            <!-- Secondary Button -->
            <button
              phx-click="create_text_block"
              class="bg-gray-700 hover:bg-gray-600 py-2 px-4 rounded-lg transition duration-200 ease-in-out flex-1 text-center">
              Add text block
            </button>
          </li>
        </ul>
      </div>
    """
  end

  @doc """
    Init func that is run on init of the view
  """
  def mount(%{ "id" => id}, _session, socket) do
    # get the document initial data and the texts
    document = case LeafNode.Core.Documents.get_document(id) do
      {:ok, data} ->
        data
      {:error, err} ->
        IO.inspect("There was a problem getting the document: #{id} with error: #{err}")
        %{}
    end

    # we add the id to the socket so we have the data for later if needed
    socket =
      assign(socket, :id, id)
      |> assign(:document, document)
      |> assign(:texts, get_document_texts(id))
    {:ok, socket}
  end

  @doc """
    The events to manage the creation of documents
  """
  def handle_event("document_execute", _params, socket) do
    IO.inspect("Execute Document")
    {:noreply, socket}
  end

  def handle_event("document_settings", _params, socket) do
    IO.inspect("Opening document settings")
    {:noreply, socket}
  end

  def handle_event("save_document", _params, socket) do
    IO.inspect("Save document settings")
    {:noreply, socket}
  end

  def handle_event("create_text_block", _params, socket) do
    IO.inspect("Create Text Block")
    # TODO: Pattern mathc here but i dont know the struct of the socket
    id = socket.assigns.id
    texts = case LeafNode.Core.Text.create_text(%{ "document_id" => id}) do
      {:ok, data} ->
        IO.inspect(data)
        get_document_texts(id)
      {:error, err} ->
        IO.inspect("Error get the geting texts for the document: #{id} with the error #{err}")
        get_document_texts(id)
    end

    {:noreply, assign(socket, :texts, texts)}
  end

  def handle_event("delete_text_block", %{ "id" => id, "value" => _}, socket) do
    texts = case LeafNode.Core.Text.edit_text(%{
        "id" => id,
        "is_deleted" => "true"
      }) do
      {:ok, _data} ->
        get_document_texts(socket.assigns.id)
      {:error, err} ->
        IO.inspect("Error get the geting texts for the document: #{id} with the error #{err}")
        get_document_texts(socket.assigns.id)
    end

    {:noreply, assign(socket, :texts, texts)}
  end

  def handle_event("generate_text_code", %{ "id" => id}, socket) do
    IO.inspect("Generate code for text block")
    texts = case LeafNode.Core.Text.generate_code(id) do
      {:ok, _data} ->
        get_document_texts(socket.assigns.id)
      {:error, err} ->
        IO.inspect("Error get the geting texts for the document: #{id} with the error #{err}")
        get_document_texts(socket.assigns.id)
    end
    {:noreply, assign(socket, :texts, texts)}
  end

  def handle_event("update_text_block", params, socket) do
    %{ "_target" => [item]} = params
    %{ "_target" => _, ^item => text_value} = params
    # You can fetch the ID from the `phx-value` attribute using the following
    # we are debouncing and will generate a save attempt of the block then
    payload = %{
      "id" => String.split(item, "content-") |> Enum.at(1),
      "data" => String.trim(text_value)
    }
    # document id relevant to the texts
    id = socket.assigns.id
    texts = case LeafNode.Core.Text.edit_text(payload) do
      {:ok, _data} ->
        get_document_texts(id)
      {:error, err} ->
        IO.inspect("Error get the geting texts for the document: #{id} with the error #{err}")
        get_document_texts(id)
    end

    IO.inspect(texts)
    {:noreply, assign(socket, :texts, texts)}
  end


  # helper functions that get details
  # TODO: return object of the texts so we can update pieces when doing changes and not rerender whole list
  defp get_document_texts(id) do
    {status, texts} = LeafNode.Core.Text.list_texts(id)
    case status do
      :ok -> Enum.map(texts, fn item -> item end)
      _ -> []
    end
  end
end
