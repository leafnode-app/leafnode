defmodule LeafNodeWeb.NodesLive do
  @doc """
    Init func that is run on init of the view
  """

  use LeafNodeWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    agent = case LeafNode.Repo.Agent.get_agent(socket.assigns.current_user.id) do
      {:ok, agent} -> %{ id: agent.id, email: agent.email}
      _ -> false
    end

    socket = socket
      |> assign(:nodes, get_nodes(socket))
      |> assign(:agent, agent)
    {:ok, socket}
  end

  # Render function
  def render(assigns) do
    ~H"""
      <!-- Header -->
      <div>
        <div class="premium-border flex justify-between items-center mt-5 mb-2 gap-2 rounded px-4 py-2 bg-gray-900">
          <div class="flex flex-col pb-1">
            <div class="flex flex-row items-center justify-content gap-4">
              <%= Heroicons.icon("arrow-path", type: "solid", class: "h-10 w-5 hover:cursor-pointer", phx_click: "regenerate_agent_email") %>
              <div
                class="text-blue-400 text-sm rounded-lg border-stone-900 block"
              >
                <%= if @agent, do: @agent.email, else: "No Agent Email" %>
              </div>
            </div>
            <p class="text-xs text-gray-300"><%= gettext("Generate/Regenerate an email address you can use to communicate with your agent") %></p>
            <p class="text-xs text-gray-300"><%= gettext("Agent will listen and using Notion, answer questions using relevant node") %></p>
          </div>
          <button
            phx-click="node_create"
            class="bg-blue-700 hover:bg-blue-600 py-2 px-4 text-sm rounded transition duration-200 ease-in-out">
            <%= gettext("Create node") %>
          </button>
        </div>

        <%= if is_nil(@nodes) or Kernel.length(@nodes) < 1 do %>
          <p class="text-gray-500 px-4 py-4"> <%= gettext("There are no nodes, create a new one to get started") %></p>
        <% else %>
          <ul class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mt-4">
            <%= for node <- @nodes do %>
              <li phx-click="node_edit" phx-value-id={node.id} class="relative border border-gray-700 bg-zinc-800 hover:bg-zinc-900 transition duration-200 ease-in-out rounded-lg">
                <div class="block cursor-pointer p-4 h-full">
                  <div class="flex flex-col justify-between h-full">
                    <div class="mb-2 flex items-center gap-3 justify-between">
                      <div class="flex items-center gap-2">
                        <%= if node.enabled do %>
                          <%= Heroicons.icon("play", type: "mini", class: "h-4 w-4 text-green-400") %>
                        <% else %>
                          <%= Heroicons.icon("pause", type: "mini", class: "h-4 w-4 text-yellow-400") %>
                        <% end %>
                      </div>
                      <h2 class="text-lg flex items-center font-semibold text-white truncate text-ellipsis">
                        <%= node.title %>
                      </h2>
                      <button phx-click="node_delete" phx-value-id={node.id} class="ml-auto">
                        <%= Heroicons.icon("x-mark", type: "outline", class: "h-6 w-6 text-red-700 hover:text-red-400 transition duration-200 ease-in-out") %>
                      </button>
                    </div>

                    <p class="text-gray-400 text-xs truncate text-ellipsis">
                      <%= node.id %>
                    </p>
                    <p class="text-gray-400 mt-3 truncate text-ellipsis">
                      <%= node.description %>
                    </p>
                  </div>
                </div>
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

  def handle_event("regenerate_agent_email", _, socket) do
    user_id = socket.assigns.current_user.id
    socket =
      case LeafNode.Repo.Agent.regenerate_email(user_id) do
        {:ok, _} ->
          {_, agent} = LeafNode.Repo.Agent.get_agent(user_id)
          socket |> assign(:agent, %{ id: agent.id, email: agent.email})
        {:error, _err} ->
          {status, _} = LeafNode.Repo.Agent.create_agent(user_id)
          # TODO: move this to be better, maybe generate if not found?
          # Here we get the newely made SUCCESSFUL agent
          if status == :ok do
            {_, agent} = LeafNode.Repo.Agent.get_agent(user_id)
            socket |> assign(:agent, %{ id: agent.id, email: agent.email})
          else
            socket |> assign(:agent, false)
          end
      end

    {:noreply, socket}
  end

  def handle_event("node_edit", %{"id" => id, "value" => _}, socket) do
    IO.inspect(id)
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
