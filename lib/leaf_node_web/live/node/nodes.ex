defmodule LeafNodeWeb.NodesLive do
  use LeafNodeWeb, :live_view

  @doc """
    Init func that is run on init of the view
  """
  def mount(_params, _session, socket) do
    # get the new list that we send off
    {:ok, assign(socket, :nodes, get_nodes(socket))}
  end

  # Render function
  def render(assigns) do
    ~H"""
      <!-- Header -->
      <div class="flex justify-between items-center mb-4">
        <h1 class="text-2xl font-semibold mb-1">Nodes</h1>
        <!-- Primary Button -->
        <button
          phx-click="node_create"
          class="bg-blue-700 hover:bg-blue-600 py-2 px-4 text-sm rounded transition duration-200 ease-in-out">
          Create
        </button>
      </div>
      <%= if is_nil(@nodes) or Kernel.length(@nodes) < 1 do %>
        <p> There are no documents, create a new one to get started</p>
      <% else %>
        <ul class="space-y-4">
          <%= for node <- @nodes do %>
            <li phx-click="node_edit" phx-value-id={node.id} >
              <a class="cursor:pointer block bg-gray-700 hover:bg-gray-600 transition duration-200 ease-in-out p-4 rounded-lg">
                <div class="flex justify-between items-center">
                  <div>
                    <h2 class="text-lg font-semibold text-white">
                      <%= node.title %>
                    </h2>
                    <p class="text-gray-400">
                      <%= node.description %>
                    </p>
                    <p class="text-gray-400 text-sm">
                      <%= node.id %>
                    </p>
                  </div>
                  <div class="space-x-2">
                    <%!-- <!-- Primary Button -->
                    <button phx-click="node_edit" phx-value-id={node.id} class="bg-blue-700 hover:bg-blue-600 text-white py-1 px-3 rounded text-sm transition duration-200 ease-in-out">
                      Edit
                    </button> --%>
                    <!-- Destructive Button -->
                    <button phx-click="node_delete" phx-value-id={node.id} class="bg-red-700 hover:bg-red-600 text-white py-1 px-3 rounded text-sm transition duration-200 ease-in-out">
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
    The events to manage the creation of documents
  """
  def handle_event("node_create", _, socket) do
    user = socket.assigns.current_user
    socket = case LeafNode.Node.create_node(user.id) do
      {:ok, data} ->
        socket = put_flash(socket, :info, "Successfully created node")
        push_navigate(socket, to: "/dashboard/node/#{data.id}")
      {:error, _err} ->
        socket
    end
    {:noreply, socket}
  end

  def handle_event("node_edit", %{ "id" => id, "value" => _}, socket) do
    socket = push_navigate(socket, to: "/dashboard/node/#{id}")
    {:noreply, socket}
  end

  def handle_event("node_delete", %{ "id" => id, "value" => _}, socket) do
    nodes = case LeafNode.Node.delete_node(id) do
      {:ok, _data} ->
        get_nodes(socket)
      {:error, err} ->
        []
    end

    socket = assign(socket, :nodes, nodes)
    {:noreply, socket}
  end

  # helper functions to manage the reuse of certain calls
  defp get_nodes(socket) do
    user = socket.assigns.current_user
    case LeafNode.Node.list_nodes(user.id) do
      {:ok, data} ->
        data
      {:error, _err} ->
        IO.inspect("There was an error getting the documents")
        []
    end
  end
end
