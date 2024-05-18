defmodule LeafNodeWeb.Components.NodeSettings do
  @moduledoc """
    General node conditions and side effects that needs to be run
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
      <div class="flex-1 bg-zinc-900 h-100% py-4 px-2 rounded-lg border border-stone-900">
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
    """
  end
end
