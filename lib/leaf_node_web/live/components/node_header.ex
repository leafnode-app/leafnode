defmodule LeafNodeWeb.Components.NodeHeader do
  @moduledoc """
    The base component to manage the node header seciton
  """
  use Phoenix.LiveComponent
  alias LeafNodeWeb.Router.Helpers, as: Routes

  attr :node, :map, required: true

  def render(assigns) do
    ~H"""
      <div>
        <div phx-click="back_home" phx-target={@myself} class="text-white cursor-pointer mx-2 mb-2">  &larr; Back </div>
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

    payload = %{
      "id" => assigns.node.id,
      "title" => text_value
    }

    {:noreply, assign(socket, :node, update_node(payload))}
  end

  def handle_event("update_description", params, %{assigns: assigns} = socket) do
    %{"_target" => [item]} = params
    %{"_target" => _, ^item => text_value} = params

    payload = %{
      "id" => assigns.node.id,
      "description" => text_value
    }

    {:noreply, assign(socket, :node, update_node(payload))}
  end

  # TODO: move this to a more global util
  defp update_node(node) do
    node_id = node["id"]
    case LeafNode.Core.Node.edit_node(node) do
      {:ok, _data} ->
        case LeafNode.Core.Node.get_node(node_id) do
          {:ok, data} ->
            data

          {:error, err} ->
            IO.inspect(
              "There was a problem getting the node: #{node_id} with error: #{err}"
            )

            %{}
        end

      {:error, err} ->
        IO.inspect(
          "There was a problem getting the node to update: #{node_id} with error: #{err}"
        )

        %{}
    end
  end
end
