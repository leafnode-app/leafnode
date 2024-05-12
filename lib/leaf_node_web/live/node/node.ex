defmodule LeafNodeWeb.NodeLive do
  use LeafNodeWeb, :live_view

  @doc """
    Init func that is run on init of the view
  """
  def mount(params, _session, socket) do
    %{"id" => id} = params

    node =
      case LeafNode.Node.get_node(id) do
        {:ok, data} ->
          data

        {:error, err} ->
          IO.inspect("There was a problem getting the node: #{id} with error: #{err}")
          %{}
      end

    # we add the id to the socket so we have the data for later if needed
    socket =
      assign(socket, :id, id)
      |> assign(:node, node)
      |> assign(:loading, nil)

    {:ok, socket}
  end

  # Render function
  def render(assigns) do
    ~H"""
      <!-- Header -->
      <div phx-click="back_home" class="text-white cursor-pointer mx-2 mb-2"> back </div>

      <div class="flex flex-col gap-1 py-1">
        <div class="bg-zinc-900 rounded-lg py-4 px-2 border border-stone-900">
          <div class="flex gap-3 p-2">
            <div class="flex-grow"><%= @node.title %></div>
            <div class="px-1 cursor-pointer">
                <i class="fa-solid fa-gear"></i>
              </div>
          </div>
        </div>
      </div>

      <%!-- <form>
          <div class="mb-4">
            <label for="node-title" class="text-l font-semibold text-white">Title</label>
            <input
              id="node-title"
              phx-debounce="200"
              phx-change="update_title"
              phx-value-id={"#{@node.id}-#{@node.title}"}
              name={"node-title"}
              class="rounded p-2 w-full text-black"
              value={@node.title || "Untitled Document"}
            />
          </div>

          <div class="mb-4">
            <label for="node-description" class="text-l font-semibold text-white">Description</label>
            <input
              id="node-description"
              phx-debounce="200"
              phx-change="update_description"
              phx-value-id={"#{@node.id}-#{@node.description}"}
              name={"node-description"}
              class="rounded p-2 w-full text-black"
              value={@node.description || "Untitled Document"}
            />
          </div>

          <h6 class="text-sm text-white"><%= @node.id %></h6>
        </form> --%>

      <div class="flex flex-col md:flex-row gap-1 justify-center">
        <div class="flex flex-col grow bg-zinc-900 rounded-lg p-4 w-full md:w-80 border border-stone-900">
          <div class="h-3/5 relative">
            <div id="chart" />
          </div>

          <div class="h-2/5 bg-grey-500 p-1">
            <div class="mb-2 border-b border-zinc-900 dark:border-zinc-900">
              <ul
                class="flex flex-wrap mb-px text-sm font-medium text-center"
                role="tablist"
              >
                <li class="me-2">
                  <div class="inline-block p-4 border-b-2 rounded-t-lg">
                    Logs
                  </div>
                </li>
              </ul>
            </div>

            <%!-- Logs --%>
            <ul class="divide-y divide-zinc-900 dark:border-zinc-900 px-2">
              <li class="py-2 sm:py-2">
                <div class="flex items-center space-x-4 rtl:space-x-reverse">
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-900 truncate dark:text-white">
                      Item 1
                    </p>
                    <p class="text-sm text-gray-500 truncate dark:text-gray-400">
                      2018-09-19T01:30:00.000Z
                    </p>
                  </div>
                  <div class="inline-flex items-center text-base font-semibold text-gray-900 dark:text-white">
                    <span class="bg-red-100  text-xs font-medium me-2 px-2.5 py-0.5 rounded dark:bg-red-700">
                      Failed
                    </span>
                  </div>
                </div>
              </li>
              <li class="py-2 sm:py-2">
                <div class="flex items-center space-x-4 rtl:space-x-reverse">
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-900 truncate dark:text-white">
                      Item 2
                    </p>
                    <p class="text-sm text-gray-500 truncate dark:text-gray-400">
                      2018-09-19T01:30:00.000Z
                    </p>
                  </div>
                  <div class="inline-flex items-center text-base font-semibold text-gray-900 dark:text-white">
                    <span class="bg-green-100 text-xs font-medium me-2 px-2.5 py-0.5 rounded dark:bg-green-700">
                      Success
                    </span>
                  </div>
                </div>
              </li>
              <li class="py-2 sm:py-2 hover:bg-light-300">
                <div class="flex items-center space-x-4 rtl:space-x-reverse">
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-900 truncate dark:text-white">
                      Item 3
                    </p>
                    <p class="text-sm text-gray-500 truncate dark:text-gray-400">
                      2018-09-19T01:30:00.000Z
                    </p>
                  </div>
                  <div class="inline-flex items-center text-base font-semibold text-gray-900 dark:text-white">
                    <span class="bg-green-100 text-xs font-medium me-2 px-2.5 py-0.5 rounded dark:bg-green-700">
                      Success
                    </span>
                  </div>
                </div>
              </li>
            </ul>
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
            <div class="flex gap-3 p-2">
              <div class="flex-grow">title</div>
              <div class="px-1 cursor-pointer">
                  <i class="fa-solid fa-gear"></i>
                </div>
            </div>

            <div class="flex align-center justify-center items-center my-3 gap-3">
              <input
                type="text"
                id="disabled-input"
                aria-label="disabled input"
                class="box_input_inset_shadow disabledmb-6 text-gray-900 text-sm rounded-lg border-stone-900 block w-full p-4 cursor-not-allowed dark:text-gray-400"
                value="https://leafnode.app/dispatch/[SOME_NODE_ID]"
                disabled
              />
              <div class="p-3 cursor-pointer">
                <i class="fa-regular fa-copy"></i>
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

  def handle_event("back_home", _params, socket) do
    {:noreply, socket |> push_navigate(to: "/dashboard")}
  end

  def handle_event("update_title", params, socket) do
    %{"_target" => [item]} = params
    %{"_target" => _, ^item => text_value} = params

    # node id relevant to the texts
    id = socket.assigns.id

    payload = %{
      "id" => id,
      "title" => text_value
    }

    node =
      case LeafNode.Node.edit_node(payload) do
        {:ok, _data} ->
          case LeafNode.Node.get_node(socket.assigns.id) do
            {:ok, data} ->
              data

            {:error, err} ->
              IO.inspect(
                "There was a problem getting the node: #{socket.assigns.id} with error: #{err}"
              )

              %{}
          end

        {:error, err} ->
          IO.inspect(
            "There was a problem getting the node: #{socket.assigns.id} with error: #{err}"
          )

          %{}
      end

    {:noreply, assign(socket, :node, node)}
  end

  def handle_event("update_description", params, socket) do
    %{"_target" => [item]} = params
    %{"_target" => _, ^item => text_value} = params

    # node id relevant to the texts
    id = socket.assigns.id

    payload = %{
      "id" => id,
      "description" => text_value
    }

    node =
      case LeafNode.Node.edit_node(payload) do
        {:ok, _data} ->
          case LeafNode.Node.get_node(socket.assigns.id) do
            {:ok, data} ->
              data

            {:error, err} ->
              IO.inspect(
                "There was a problem getting the node: #{socket.assigns.id} with error: #{err}"
              )

              %{}
          end

        {:error, err} ->
          IO.inspect(
            "There was a problem getting the node: #{socket.assigns.id} with error: #{err}"
          )

          %{}
      end

    {:noreply, assign(socket, :node, node)}
  end

  # handle info is used to manage events on channels
  def handle_info({:loading, text_block_id}, socket) do
    {:noreply, assign(socket, loading: text_block_id)}
  end
end
