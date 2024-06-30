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

    {status, expression} = LeafNode.Repo.Expression.get_expression_by_node(id)
    expr = if status === :ok, do: expression, else: %{}

    socket =
      assign(socket, :id, id)
      |> assign(:node, node)
      |> assign(:logs, log_list)
      |> assign(:expression, expr)
      |> assign(:live_action, nil)
      |> assign(:current_user, socket.assigns.current_user)

    send(self(), :sync_has_oauth)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={NodeHeader} id="node_header" node={@node} />
    <div class="my-2" />
    <.live_component module={NodeClause} id="node_clause" expression={@expression} />
    <div class="my-2" />
    TODO: Setup the process input section here
    <div class="my-2" />
    <.live_component module={NodeIntegration} id="node_integrations" node={@node} current_user={@current_user} />
    <div class="my-2" />
    <.live_component module={NodeDetails} id="node_details" node={@node} />
    <div class="my-2" />
    <.live_component module={NodeLogs} id="node_logs" logs={@logs} node={@node} />
    """
  end

  def handle_event("update_integration", values, %{assigns: assigns} = socket) do
    node = assigns.node || false
    user = assigns.current_user || false

    case node do
      false -> {:noreply, socket}
      _ ->
        values_check = if values["type"] === "none",
          do: %{ "type" => "none", "input" => nil, "has_oauth" => false },
          else: Map.merge(node.integration_settings, values)

        payload = %{"id" => node.id, "integration_settings" => values_check}
        {status, updated_node} = update_node(payload, node)

        socket =
          socket
          |> assign(:node, updated_node)

        # TODO: move this to a new function as its only purpose is
        updated_node = if status === :ok do
          node = updated_node
          integration_payload = Map.merge(node.integration_settings, values)
          type = integration_payload["type"]

          integration_token = if type !== "none" do
            LeafNode.Repo.OAuthToken.get_token(user.id, String.split(type, "_") |> Enum.at(0))
          end

          has_oauth = if integration_token, do: true, else: false
          payload =
            %{
              "id" => node.id,
              "integration_settings" =>
                Map.merge(node.integration_settings, %{ "has_oauth" => has_oauth })
            }

          {_, updated_node} = update_node(payload, node)
          updated_node
        end

        socket =
          socket
          |> assign(:node, updated_node)

        {:noreply, socket}
    end
  end

  def handle_event("toggle_enabled", _, %{assigns: assigns} = socket) do
    node = assigns.node || false

    case node do
      false -> {:noreply, socket}
      _ ->
        payload = %{"id" => node.id, "enabled" => !node.enabled}
        {_status, updated_node} = update_node(payload, node)
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
        {_status, updated_node} = update_node(payload, node)
        socket =
          socket
          |> assign(:node, updated_node)
          |> assign(:should_log, updated_node.should_log || false)

        {:noreply, socket}
    end
  end

  @doc """
    Sending an event to itself in order to async manage and compute some data
  """
  def handle_info(:sync_has_oauth, socket) do
    %{current_user: current_user, node: node} = socket.assigns
    # Get the relevant integration
    type = String.split(node.integration_settings["type"], "_") |> Enum.at(0)
    token = LeafNode.Repo.OAuthToken.get_token(current_user.id, type)

    updated_integration_settings = Map.put(node.integration_settings, "has_oauth", !is_nil(token))
    updated_node = Map.put(node, :integration_settings, updated_integration_settings)
    {:noreply, assign(socket, :node, updated_node)}
  end

  defp update_node(node_partial, prev_node) do
    node_id = node_partial["id"]
    case LeafNode.Repo.Node.edit_node(node_partial) do
      {:ok, _data} ->
        case LeafNode.Repo.Node.get_node(node_id) do
          {:ok, data} ->
            {:ok, data}
          {:error, err} ->
            IO.inspect("There was a problem getting the node: #{node_id} with error: #{err}")
            {:error, prev_node}
        end
      {:error, err} ->
        IO.inspect("There was a problem getting the node to update: #{node_id} with error: #{err}")
        {:error, prev_node}
    end
  end
end
