defmodule LeafNodeWeb.NodeLive do
  use LeafNodeWeb, :live_view

  @doc """
    Init func that is run on init of the view
  """
  def mount(params, _session, socket) do
    %{ "id" => id} = params

    node = case LeafNode.Node.get_node(id) do
      {:ok, data} ->
        data
      {:error, err} ->
        IO.inspect("There was a problem getting the node: #{id} with error: #{err}")
        %{}
    end

    # we add the id to the socket so we have the data for later if needed
    socket =
      assign(socket, :id, id)
      |> assign(:node, node)
      |> assign(:loading, nil)
    {:ok, socket}
  end

  # Render function
  def render(assigns) do
    ~H"""
      <!-- Header -->
      <div class="mb-4">
        <div phx-click="back_home" class="text-white cursor-pointer"> back </div>
        <form>
          <div class="mb-4">
            <label for="node-title" class="text-l font-semibold text-white">Title</label>
            <input
              id="node-title"
              phx-debounce="200"
              phx-change="update_title"
              phx-value-id={"#{@node.id}-#{@node.title}"}
              name={"node-title"}
              class="rounded p-2 w-full text-black"
              value={@node.title || "Untitled Document"}
            />
          </div>

          <div class="mb-4">
            <label for="node-description" class="text-l font-semibold text-white">Description</label>
            <input
              id="node-description"
              phx-debounce="200"
              phx-change="update_description"
              phx-value-id={"#{@node.id}-#{@node.description}"}
              name={"node-description"}
              class="rounded p-2 w-full text-black"
              value={@node.description || "Untitled Document"}
            />
          </div>

          <h6 class="text-sm text-white"><%= @node.id %></h6>
        </form>
      </div>
    """
  end

  def handle_event("back_home", _params, socket) do
    {:noreply, socket |> push_navigate(to: "/dashboard")}
  end

  def handle_event("update_title", params, socket) do
    %{ "_target" => [item]} = params
    %{ "_target" => _, ^item => text_value} = params

     # node id relevant to the texts
    id = socket.assigns.id
    payload = %{
      "id" => id,
      "title" => text_value
    }

    node = case LeafNode.Node.edit_node(payload) do
      {:ok, _data} ->
        case LeafNode.Node.get_node(socket.assigns.id) do
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

    node = case LeafNode.Node.edit_node(payload) do
      {:ok, _data} ->
        case LeafNode.Node.get_node(socket.assigns.id) do
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
end
