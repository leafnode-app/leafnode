defmodule LeafNodeWeb.Web.Live.Node do
  use LeafNodeWeb, :live_view

  @doc """
    Init func that is run on init of the view
  """
  def mount(params, _session, socket) do
    %{ "id" => id} = params
    IO.inspect(params, label: "params")
    # get the node initial data and the texts
    # node = case nil do
    #   {:ok, data} ->
    #     data
    #   {:error, err} ->
    #     IO.inspect("There was a problem getting the node: #{id} with error: #{err}")
    #     %{}
    # end

    # we add the id to the socket so we have the data for later if needed
    socket =
      assign(socket, :id, id)
      # |> assign(:node, node)
      |> assign(:node, %{ id: "test", name: "test", description: "test", result: "test"})
      |> assign(:texts, get_document_texts(id))
      |> assign(:loading, nil)
    {:ok, socket}
  end

  # Render function
  def render(assigns) do
    ~H"""
      <!-- Header -->
      <div class="mb-4">
        <form>
          <div class="mb-4">
            <label for="node-title" class="text-l font-semibold text-gray-400">Title</label>
            <input
              id="node-title"
              phx-debounce="200"
              phx-change="update_title"
              phx-value-id={"#{@node.id}-#{@node.name}"}
              name={"node-name"}
              class="bg-gray-600 rounded p-2 w-full text-white"
              value={@node.name || "Untitled Document"}
            />
          </div>

          <div class="mb-4">
            <label for="node-description" class="text-l font-semibold text-gray-400">Description</label>
            <input
              id="node-description"
              phx-debounce="200"
              phx-change="update_description"
              phx-value-id={"#{@node.id}-#{@node.description}"}
              name={"node-description"}
              class="bg-gray-600 rounded p-2 w-full text-white"
              value={@node.description || "Untitled Document"}
            />
          </div>

          <h6 class="text-sm text-gray-400"><%= @node.id %></h6>
          <h6 class="text-sm text-gray-400">Document result: <%= @node.result %></h6>
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
        </form>
      </div>


      <!-- Vertical Timeline -->
      <div class="relative">
        <div class="absolute top-0 h-full w-0.5 bg-gray-500"></div>
        <ul class="space-y-4">
          <%= for text_block <- @texts do %>
            <li class="bg-gray-700 p-4 ml-5 rounded-lg flex">
              <div class={"rounded-full h-6 w-6 mt-2 #{if @node.result === text_block.id, do: "bg-blue-300", else: "bg-gray-500"}"}></div>
              <div class="flex-1 ml-4 overflow-auto">
                <div class="flex justify-between">
                  <div class="text-gray-400 text-xs mb-2"><%= text_block.id %> </div>
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
                    <pre class="text-gray-300 text-sm overflow-hidden"><%= text_block.pseudo_code %></pre>
                  </div>
                  <div class="py-3 text-sm">
                    <form id={"form-set-result-#{text_block.id}"}>
                      <input
                        phx-change="set_document_result"
                        name={"node-result-toggle-#{text_block.id}"}
                        phx-value-id={text_block.id}
                        checked={@node.result === text_block.id}
                        type="checkbox" class="mx-2 custom-checkbox form-checkbox h-4 w-4 text-blue-600"
                      >
                      Set as node result
                    </form>
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
    The events to manage the creation of documents
  """
  def handle_event("document_execute", _params, socket) do
    IO.inspect("Execute Document")
    {:noreply, socket}
  end

  def handle_event("document_settings", _params, socket) do
    IO.inspect("Opening node settings")
    {:noreply, socket}
  end

  def handle_event("save_document", _params, socket) do
    IO.inspect("Save node settings")
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
        IO.inspect("Error get the geting texts for the node: #{id} with the error #{err}")
        get_document_texts(id)
    end

    {:noreply, assign(socket, :texts, texts)}
  end

  def handle_event("set_document_result", params, socket) do
    %{ "_target" => [item]} = params

    # we will not get data on a false value, so we make a fallback for a false state match
    result_toggle_check = try do
      %{ "_target" => _, ^item => state} = params
      %{ "item" => item, "status" => state}
    rescue _e ->
      %{ "item" => item, "status" => "false" }
    end

    # compare the status of checkbox with a default on false set
    %{ "item" => item, "status" => status} = result_toggle_check

    # create relevant payload based on false but compare if selected result - false (turn off)
    result = if status === "false" do
      Map.get(socket.assigns, "result") === item
      "false"
    else
      String.split(item, "node-result-toggle-") |> Enum.at(1)
    end

    # payload for node update
    payload = %{
      "id" => socket.assigns.id,
      "result" => result
    }

    node = case LeafNode.Core.Documents.edit_document(payload) do
      {:ok, _data} ->
        case LeafNode.Core.Documents.get_node(socket.assigns.id) do
          {:ok, data} ->
            data
          {:error, err} ->
            IO.inspect("There was a problem getting the node: #{socket.assigns.id} with error: #{err}")
            %{}
          end
      {:error, err} ->
        IO.inspect("There was a problem getting the node: #{socket.assigns.id} with error: #{err}")
        %{}
    end

    # # we add the id to the socket so we have the data for later if needed
    socket = assign(socket, :node, node)

    {:noreply, socket}
  end

  def handle_event("delete_text_block", %{ "id" => id, "value" => _}, socket) do
    texts = case LeafNode.Core.Text.edit_text(%{
        "id" => id,
        "is_deleted" => "true"
      }) do
      {:ok, _data} ->
        get_document_texts(socket.assigns.id)
      {:error, err} ->
        IO.inspect("Error get the geting texts for the node: #{id} with the error #{err}")
        get_document_texts(socket.assigns.id)
    end

    {:noreply, assign(socket, :texts, texts)}
  end

  def handle_event("generate_text_code", %{ "id" => id}, socket) do
    # start loader
    # Phoenix.PubSub.broadcast(LeafNode.PubSub, "doc-channel-#{socket.assigns.id}", {:loading, id})

    texts = case LeafNode.Core.Text.generate_code(id) do
      {:ok, _data} ->
        get_document_texts(socket.assigns.id)
      {:error, err} ->
        IO.inspect("Error get the geting texts for the node: #{id} with the error #{err}")
        get_document_texts(socket.assigns.id)
    end
    # Phoenix.PubSub.broadcast(LeafNode.PubSub, "doc-channel-#{socket.assigns.id}", {:loading, nil})
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
    # node id relevant to the texts
    id = socket.assigns.id
    texts = case LeafNode.Core.Text.edit_text(payload) do
      {:ok, _data} ->
        get_document_texts(id)
      {:error, err} ->
        IO.inspect("Error get the geting texts for the node: #{id} with the error #{err}")
        get_document_texts(id)
    end

    {:noreply, assign(socket, :texts, texts)}
  end

  def handle_event("update_title", params, socket) do
    %{ "_target" => [item]} = params
    %{ "_target" => _, ^item => text_value} = params

     # node id relevant to the texts
    id = socket.assigns.id
    payload = %{
      "id" => id,
      "name" => text_value
    }

    node = case LeafNode.Core.Documents.edit_document(payload) do
      {:ok, _data} ->
        case LeafNode.Core.Documents.get_node(socket.assigns.id) do
          {:ok, data} ->
            data
          {:error, err} ->
            IO.inspect("There was a problem getting the node: #{socket.assigns.id} with error: #{err}")
            %{}
          end
      {:error, err} ->
        IO.inspect("There was a problem getting the node: #{socket.assigns.id} with error: #{err}")
        %{}
    end

    {:noreply, assign(socket, :node, node)}
  end

  def handle_event("update_description", params, socket) do
    %{ "_target" => [item]} = params
    %{ "_target" => _, ^item => text_value} = params

     # node id relevant to the texts
    id = socket.assigns.id
    payload = %{
      "id" => id,
      "description" => text_value
    }

    node = case LeafNode.Core.Documents.edit_document(payload) do
      {:ok, _data} ->
        case LeafNode.Core.Documents.get_node(socket.assigns.id) do
          {:ok, data} ->
            data
          {:error, err} ->
            IO.inspect("There was a problem getting the node: #{socket.assigns.id} with error: #{err}")
            %{}
          end
      {:error, err} ->
        IO.inspect("There was a problem getting the node: #{socket.assigns.id} with error: #{err}")
        %{}
    end

    {:noreply, assign(socket, :node, node)}
  end

  # handle info is used to manage events on channels
  def handle_info({:loading, text_block_id}, socket) do
    {:noreply, assign(socket, loading: text_block_id)}
  end


  # helper functions that get details
  # TODO: return object of the texts so we can update pieces when doing changes and not rerender whole list
  defp get_document_texts(id) do
    # {status, texts} = LeafNode.Core.Text.list_texts(id)
    # case status do
    #   :ok -> Enum.map(texts, fn item -> item end)
    #   _ -> []
    # end
    []
  end
end
