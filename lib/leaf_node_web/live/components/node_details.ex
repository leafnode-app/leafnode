defmodule LeafNodeWeb.Components.NodeDetails do
  @moduledoc """
    The details around interacting with the node and controls to set logging and node availibility
  """
  use Phoenix.LiveComponent

  attr :node, :map, required: true

  def render(assigns) do
    ~H"""
      <div class="flex-1 bg-zinc-900 py-4 px-2 h-100% rounded-lg border border-stone-900">
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
        <form class="flex flex-col gap-3">
          <label class="flex items-center cursor-pointer px-2">
            <span class="flex-1 font-medium text-gray-900 dark:text-gray-300">Enable</span>
            <div>
              <input type="checkbox" phx-change="toggle_enabled" checked={@node.enabled} value="" class="sr-only peer" />
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
              <input type="checkbox" phx-change="toggle_should_log" checked={@node.should_log} value="" class="sr-only peer" />
              <div class="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:zinc-gray-300 dark:peer-focus:ring-zinc-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-green-700"></div>
            </div>
          </label>
        </form>
      </div>
    """
  end

end
