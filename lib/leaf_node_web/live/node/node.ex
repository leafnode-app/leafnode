defmodule LeafNodeWeb.NodeLive do
  use LeafNodeWeb, :live_view

  # import components
  alias LeafNodeWeb.Components.NodeHeader

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

    # TODO: We need a async fetch of logs and paginated down the line
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

      <div class="flex flex-col md:flex-row gap-1 justify-center">
        <div class="flex flex-col grow bg-zinc-900 rounded-lg p-4 w-full md:w-80 border border-stone-900">
          <div class="h-full bg-grey-500 p-1">
            <%!-- Logs --%>
            <%= if Enum.empty?(@logs) do%>
              No logs
            <%= else%>
              <ul class="divide-y divide-zinc-900 dark:border-zinc-900 px-2">
                <%= for item <- @logs do %>
                  <li class="py-2 sm:py-2">
                    <div class="flex items-center space-x-4 rtl:space-x-reverse">
                      <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium text-gray-900 truncate dark:text-white">
                          <%= item.id %>
                        </p>
                        <p class="text-sm text-gray-500 truncate dark:text-gray-400">
                          <%= item.inserted_at %>
                        </p>
                      </div>
                      <div class="inline-flex items-center text-base font-semibold text-gray-900 dark:text-white">
                      <span class={
                        "text-xs font-medium me-2 px-2.5 py-0.5 rounded" <>
                        if item.status, do: "bg-green-100 dark:bg-green-700", else: "bg-red-100 dark:bg-red-700"
                      }>
                        <%= item.status %>
                      </span>
                      </div>
                    </div>
                  </li>
                <% end %>
              </ul>
            <%= end%>
          </div>

          </div>
            <div class="flex flex-col grow gap-1 w-full md:w-80">
              <div class="flex-1 bg-zinc-900 py-4 px-2 rounded-lg border border-stone-900">
                <div>
                  <div class="flex flex-col p-4 h-full gap-1 justify-center flex-1">
                    <div class="node_block_wrapper box_input_inset_shadow cursor-pointer">
                      <pre class="px-1 text-orange-300">when :: input.message.value === "Test"</pre>
                    </div>
                    <div class="node_vertical_line self-center"></div>
                    <div class="self-center text-zinc-600 text-xl">do</div>
                    <div class="node_vertical_line self-center"></div>
                    <div class="node_block_wrapper box_input_inset_shadow cursor-pointer">
                      <pre class="text-blue-300">send_to_slack :: input.message.value</pre>
                    </div>
                  </div>
                </div>
              </div>

          <div class="flex-1 bg-zinc-900 py-4 px-2 rounded-lg border border-stone-900">
            <div>
              <input
                type="text"
                id="disabled-input"
                aria-label="disabled input"
                class="box_input_inset_shadow disabledmb-6 text-gray-900 text-sm rounded-lg border-stone-900 block w-full p-4 cursor-not-allowed dark:text-gray-400"
                value={LeafNodeWeb.Endpoint.url() <> "/api/v1/node/" <> @node.id}
                disabled
              />
              <div class="py-4">
                <div class="text-xs px-2 text-gray-600"> x-api-token: </div>
                <div class="text-xs px-2 text-gray-600"> <%= @node.access_key %> </div>
              </div>
            </div>

            <span class="bg-orange-100 text-xs font-medium mx-1 px-2 py-0.5 rounded dark:bg-orange-700">
              POST
            </span>
            <hr class="border-zinc-900 my-3"/>
            <div class="flex flex-col gap-3">
              <label class="flex items-center cursor-pointer px-2">
                <span class="flex-1 font-medium text-gray-900 dark:text-gray-300">Enable</span>
                <div>
                  <input type="checkbox" value="" class="sr-only peer" />
                  <div class="
                    relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4
                    peer-focus:ring-grey-300 dark:peer-focus:ring-zinc-800 rounded-full peer
                    dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full
                    peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px]
                    after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5
                    after:transition-all dark:border-gray-600 peer-checked:bg-green-700"></div>
                </div>
              </label>
              <label class="flex items-center cursor-pointer px-2">
                <span class="flex-1 font-medium text-gray-900 dark:text-gray-300">Logs</span>
                <div>
                  <input type="checkbox" value="" class="sr-only peer" />
                  <div class="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:zinc-gray-300 dark:peer-focus:ring-zinc-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-green-700"></div>
                </div>
              </label>
            </div>
          </div>
        </div>
      </div>
    """
  end
end
