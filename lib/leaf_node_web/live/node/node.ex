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
      <.live_component module={NodeLogs} id="node_logs_column" logs={@logs} />
    """
  end
end
