defmodule LeafNodeWeb.NodesLive do
  @doc """
    Init func that is run on init of the view
  """

  use LeafNodeWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do

    token_data = case resp = LeafNode.Repo.ExtensionToken.get_token_by_user(socket.assigns.current_user.id) do
      nil -> %{ id: nil, token: nil}
      _ -> %{ id: resp.id, token: resp.token}
    end

    socket = socket
      |> assign(:nodes, get_nodes(socket))
      |> assign(:extension_details, token_data)
    {:ok, socket}
  end

  # Render function
  def render(assigns) do
    ~H"""
      <!-- Header -->
      <div>
        <div>
          <div class="flex justify-between items-center mt-10 mb-4">
            <!-- Primary Button -->
            <div class="w-full ">
              <button
                phx-click="node_create"
                class="bg-blue-700 hover:bg-blue-600 py-2 px-4 text-sm rounded transition duration-200 ease-in-out">
                <%= gettext("Create a new node") %>
              </button>
            </div>

            <%!-- Here we show the relevant extension token --%>
            <div>
              <div class="premium-border w-auto flex justify-center gap-2 p-1">
                <input
                  type="text"
                  id="disabled-input"
                  aria-label="disabled input"
                  class="box_input_inset_shadow disabled text-zinc-800 text-sm rounded-lg border-stone-900 block dark:text-gray-400"
                  value={@extension_details.token || "No token"}
                  disabled
                />
                <button
                  phx-click="regenerate_extension_token"
                  class="bg-blue-700 hover:bg-blue-600 py-2 px-4 text-sm rounded transition duration-200 ease-in-out">
                  <%= gettext("Generate") %>
                </button>
              </div>
              <p class="text-xs text-zinc-600 pt-2"><%= gettext("Use with browser extention to access nodes") %></p>
            </div>
          </div>
        </div>
        <%= if is_nil(@nodes) or Kernel.length(@nodes) < 1 do %>
          <p class="text-gray-500"> <%= gettext("There are no nodes, create a new one to get started") %></p>
        <% else %>
          <ul class="space-y-4">
            <%= for node <- @nodes do %>
              <li phx-click="node_edit" class="cursor-pointer" phx-value-id={node.id} >
                <a class="cursor:pointer block bg-zinc-900 hover:bg-zinc-800 transition duration-200 ease-in-out p-4 rounded-lg">
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
                      <!-- Destructive Button -->
                      <button phx-click="node_delete" phx-value-id={node.id} class="bg-red-700 hover:bg-red-600 text-white py-1 px-3 rounded text-sm transition duration-200 ease-in-out">
                        <%= gettext("Delete") %>
                      </button>
                    </div>
                  </div>
                </a>
              </li>
            <% end %>
          </ul>
        <% end %>
      </div>
    """
  end

  @doc """
    The events to manage the creation of documents
  """
  def handle_event("node_create", _, socket) do
    user = socket.assigns.current_user
    socket =
      case LeafNode.Repo.Node.create_node(user.id) do
        {:ok, data} ->
          push_navigate(socket, to: "/dashboard/node/#{data.id}")

        {:error, _err} ->
          socket
      end

    {:noreply, socket}
  end

  def handle_event("regenerate_extension_token", _, socket) do
    # user = socket.assigns.current_user
    %{id: extension_id} = socket.assigns.extension_details
    socket =
      case LeafNode.Repo.ExtensionToken.regenerate_token(extension_id) do
        {:ok, _} ->
          updated_token = LeafNode.Repo.ExtensionToken.get_token_by_user(socket.assigns.current_user.id)
          socket |> assign(:extension_details, %{ id: updated_token.id, token: updated_token.token})
        {:error, _err} ->
          token = LeafNode.Repo.ExtensionToken.generate_token(socket.assigns.current_user.id, UUID.uuid4())
          socket |> assign(:extension_details, %{ id: token.id, token: token.token})
      end

    {:noreply, socket}
  end

  def handle_event("node_edit", %{"id" => id, "value" => _}, socket) do
    socket = push_navigate(socket, to: "/dashboard/node/#{id}")
    {:noreply, socket}
  end

  def handle_event("node_delete", %{"id" => id, "value" => _}, socket) do
    nodes =
      case LeafNode.Repo.Node.delete_node(id) do
        {:ok, _data} ->
          get_nodes(socket)

        {:error, _err} ->
          []
      end

    socket = assign(socket, :nodes, nodes)
    {:noreply, socket}
  end

  # helper functions to manage the reuse of certain calls
  defp get_nodes(socket) do
    user = socket.assigns.current_user

    case LeafNode.Repo.Node.list_nodes(user.id) do
      {:ok, data} ->
        data

      {:error, _err} ->
        Logger.error("There was an error getting the nodes")
        []
    end
  end
end
