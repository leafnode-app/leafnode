defmodule LeafNodeWeb.NodeLive do
  use LeafNodeWeb, :live_view

  alias LeafNodeWeb.Components.{NodeHeader, NodeLogs, NodeDetails, NodeClause, NodeIntegration}

  @doc """
  Init func that is run on init of the view
  """
  def mount(params, _session, socket) do
    %{"id" => id} = params

    node =
      case LeafNode.Repo.Node.get_node(id) do
        {:ok, data} -> data
        {:error, err} ->
          IO.inspect("There was a problem getting the node: #{id} with error: #{err}")
          %{}
      end

    {status, logs} = LeafNode.Repo.Log.list_logs(id)
    log_list = if status === :ok && is_list(logs), do: logs, else: []

    {status, expression} = LeafNode.Core.Expression.get_expression_by_node(id)
    expr = if status === :ok, do: expression, else: %{}

    socket =
      assign(socket, :id, id)
      |> assign(:node, node)
      |> assign(:logs, log_list)
      |> assign(:expression, expr)
      |> assign(:live_action, nil)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={NodeHeader} id="node_header" node={@node} />
    <div class="my-2" />
    <.live_component module={NodeClause} id="node_clause" expression={@expression} />
    <.live_component module={NodeIntegration} id="node_integrations" node={@node} />
    <div class="my-2" />
    <.live_component module={NodeDetails} id="node_details" node={@node} />
    <div class="my-2" />
    <.live_component module={NodeLogs} id="node_logs" logs={@logs} node={@node} />
    """
  end

  def handle_event("toggle_enabled", _, %{assigns: assigns} = socket) do
    node = assigns.node || false

    case node do
      false -> {:noreply, socket}
      _ ->
        payload = %{"id" => node.id, "enabled" => !node.enabled}
        updated_node = update_node(payload, node)
        socket =
          socket
          |> assign(:node, updated_node)
          |> assign(:enabled, updated_node.enabled || false)

        {:noreply, socket}
    end
  end

  def handle_event("toggle_should_log", _, %{assigns: assigns} = socket) do
    node = assigns.node || false

    case node do
      false -> {:noreply, socket}
      _ ->
        payload = %{"id" => node.id, "should_log" => !node.should_log}
        updated_node = update_node(payload, node)
        socket =
          socket
          |> assign(:node, updated_node)
          |> assign(:should_log, updated_node.should_log || false)

        {:noreply, socket}
    end
  end

  defp update_node(node, prev_node) do
    node_id = node["id"]
    case LeafNode.Repo.Node.edit_node(node) do
      {:ok, _data} ->
        case LeafNode.Repo.Node.get_node(node_id) do
          {:ok, data} -> data
          {:error, err} ->
            IO.inspect("There was a problem getting the node: #{node_id} with error: #{err}")
            prev_node
        end
      {:error, err} ->
        IO.inspect("There was a problem getting the node to update: #{node_id} with error: #{err}")
        prev_node
    end
  end
end
