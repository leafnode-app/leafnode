defmodule LeafNodeWeb.LogDetailsLive do
  use LeafNodeWeb, :live_view
  alias LeafNodeWeb.Router.Helpers, as: Routes

  @doc """
  Init func that is run on init of the view.
  """
  def mount(%{"id" => id}, _session, socket) do
    log =
      case LeafNode.Core.Log.get_log(id) do
        {:ok, data} ->
          data

        {:error, err} ->
          IO.inspect("There was a problem getting the log: #{id} with error: #{err}")
          %{}
      end

    # Add the id and log to the socket
    socket =
      assign(socket, :id, id)
      |> assign(:log, log)

    {:ok, socket}
  end

  def render(assigns) do
    input_json = Jason.encode!(assigns.log.input, pretty: true)
    result_json = Jason.encode!(assigns.log.result, pretty: true)

    ~H"""
    <div class="text-gray-300">
      <div class="container mx-auto py-8">
        <div phx-click="back_to_node" phx-value-parent_node={@log.node_id} class="text-white cursor-pointer mb-4">
          &larr; Back
        </div>
        <div class="bg-zinc-900 rounded-lg p-6 shadow-lg">
          <div class="mb-6">
            <h3 class="text-2xl font-semibold mb-2">Log Details</h3>
            <p class="text-sm text-gray-400 mb-1"><span class="font-semibold text-gray-300">Log ID:</span> <%= @log.id %></p>
            <p class="text-sm text-gray-400 mb-1"><span class="font-semibold text-gray-300">Node ID:</span> <%= @log.node_id %></p>
            <p class="text-sm text-gray-400 mb-1"><span class="font-semibold text-gray-300">Inserted At:</span> <%= @log.inserted_at %></p>
            <p class="text-sm text-gray-400 mb-1"><span class="font-semibold text-gray-300">Updated At:</span> <%= @log.updated_at %></p>
            <p class="text-sm text-gray-400"><span class="font-semibold text-gray-300">Status:</span>
              <span class={
                "text-xs font-medium mx-1 px-2 py-0.5 rounded " <>
                if @log.status, do: "bg-green-100 text-green-800 dark:bg-green-700 dark:text-green-100", else: "bg-red-100 text-red-800 dark:bg-red-700 dark:text-red-100"
              }>
                <%= if @log.status, do: "Success", else: "Failure" %>
              </span>
            </p>
          </div>

          <div class="mb-6">
            <h4 class="text-l font-semibold mb-2">Input Received:</h4>
            <pre class="bg-zinc-800 rounded-lg p-4 overflow-auto whitespace-pre-wrap"><%= input_json %></pre>
          </div>

          <div class="mb-6">
            <h4 class="text-l font-semibold mb-2">Node Result:</h4>
            <pre class="bg-zinc-800 rounded-lg p-4 overflow-auto whitespace-pre-wrap"><%= result_json %></pre>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("back_to_node", %{"parent_node" => parent_node}, socket) do
    url = Routes.live_path(socket, LeafNodeWeb.NodeLive, parent_node)
    {:noreply, push_navigate(socket, to: url)}
  end
end
