defmodule LeafNodeWeb.NodeLive do
  use LeafNodeWeb, :live_view

  # import Node Components
  alias LeafNodeWeb.Components.{NodeHeader, NodeLogs, NodeDetails, NodeSettings}

  @doc """
    Init func that is run on init of the view
  """
  def mount(params, _session, socket) do
    %{"id" => id} = params

    node =
      case LeafNode.Core.Node.get_node(id) do
        {:ok, data} ->
          data

        {:error, err} ->
          IO.inspect("There was a problem getting the node: #{id} with error: #{err}")
          %{}
      end

    {status, logs} = LeafNode.Core.Log.list_logs(id)
    log_list = if status === :ok && is_list(logs), do: logs, else: []

    # we add the id to the socket so we have the data for later if needed
    socket =
      assign(socket, :id, id)
      |> assign(:node, node)
      |> assign(:logs, log_list)

    {:ok, socket}
  end

  # Render function
  def render(assigns) do
    ~H"""
      <.live_component module={NodeHeader} id="node_header" node={@node} />
      <div class="my-2" />
      <.live_component module={NodeSettings} id="node_settings" />
      <div class="my-2" />
      <.live_component module={NodeDetails} id="node_details" node={@node} />
      <div class="my-2" />
      <.live_component module={NodeLogs} id="node_logs" logs={@logs} node={@node} />
    """
  end

  # Bubble up events that are specific for nodes that will require a re-render
  def handle_event("toggle_enabled", _, %{assigns: assigns} = socket) do
    node = assigns.node || false

    # get the node from the channel so we can try and toggle the state
    case node do
      false ->
        {:noreply, socket}
      _ ->
        payload = %{
          "id" => node.id,
          "enabled" => !node.enabled
        }

        updated_node = update_node(payload, node)
        socket = socket
          |> assign(:node, updated_node)
          |> assign(:enabled, updated_node.enabled || false)

        {:noreply, socket}
    end
  end

  def handle_event("toggle_should_log", _, %{assigns: assigns} = socket) do
    node = assigns.node || false

    # get the node from the channel so we can try and toggle the state
    case node do
      false ->
        {:noreply, socket}
      _ ->
        payload = %{
          "id" => node.id,
          "should_log" => !node.should_log
        }

        updated_node = update_node(payload, node)
        socket = socket
          |> assign(:node, updated_node)
          |> assign(:should_log, updated_node.should_log || false)

        {:noreply, socket}
    end
  end

  # TODO: move this to a more global util
  defp update_node(node, prev_node) do
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

            prev_node
        end

      {:error, err} ->
        IO.inspect(
          "There was a problem getting the node to update: #{node_id} with error: #{err}"
        )

        prev_node
    end
  end
end
