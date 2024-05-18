defmodule LeafNodeWeb.Components.NodeHeader do
  @moduledoc """
    The base component to manage the node header seciton
  """
  use Phoenix.LiveComponent
  alias LeafNodeWeb.Router.Helpers, as: Routes

  attr :node, :map, required: true

  def render(assigns) do
    ~H"""
      <div class="flex flex-col gap-1 py-1">
        <div phx-click="back_home" phx-target={@myself} class="text-white cursor-pointer mx-2 mb-2"> back </div>
        <div class="bg-zinc-900 rounded-lg py-4 px-2 border border-stone-900">
          <div class="flex gap-3 p-2">
            <form class="flex-grow">
              <label for="node-description" class="text-sm text-white">Title</label>
              <input
                id="node-title"
                phx-debounce="200"
                phx-change="update_title"
                phx-target={@myself}
                phx-value-id={"#{@node.id}-#{@node.title}"}
                name={"node-title"}
                class="rounded p-2 w-full text-black"
                value={@node.title || "Untitled Document"}
              />
              <div class="py-2"/>
              <label for="node-description" class="text-sm text-white">Description</label>
              <input
                id="node-description"
                phx-debounce="200"
                phx-change="update_description"
                phx-target={@myself}
                phx-value-id={"#{@node.id}-#{@node.description}"}
                name={"node-description"}
                class="rounded p-2 w-full text-black"
                value={@node.description || "Untitled Document"}
              />
            </form>
            <div class="px-1 cursor-pointer">
              <i class="fa-solid fa-gear"></i>
            </div>
          </div>
        </div>
      </div>
    """
  end

  def handle_event("back_home", _params, socket) do
    url = Routes.live_path(LeafNodeWeb.Endpoint, LeafNodeWeb.NodesLive)
    {:noreply, push_navigate(socket, to: url)}
  end

  def handle_event("update_title", params, %{assigns: assigns} = socket) do
    %{"_target" => [item]} = params
    %{"_target" => _, ^item => text_value} = params

    node_id = assigns.node.id
    payload = %{
      "id" => node_id,
      "title" => text_value
    }

    {:noreply, assign(socket, :node, update_node(payload, node_id))}
  end

  def handle_event("update_description", params, %{assigns: assigns} = socket) do
    %{"_target" => [item]} = params
    %{"_target" => _, ^item => text_value} = params

    node_id = assigns.node.id
    payload = %{
      "id" => node_id,
      "description" => text_value
    }

    {:noreply, assign(socket, :node, update_node(payload, node_id))}
  end

  # This is a generic crud operation against helpers to update node
  defp update_node(payload, id) do
    case LeafNode.Core.Node.edit_node(payload) do
      {:ok, _data} ->
        case LeafNode.Core.Node.get_node(id) do
          {:ok, data} ->
            data

          {:error, err} ->
            IO.inspect(
              "There was a problem getting the node: #{id} with error: #{err}"
            )

            %{}
        end

      {:error, err} ->
        IO.inspect(
          "There was a problem getting the node: #{id} with error: #{err}"
        )

        %{}
    end
  end
end
