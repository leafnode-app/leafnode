defmodule LeafNodeWeb.Components.NodeProcessing do
  @moduledoc """
    The details around interacting with the node and controls to set logging and node availibility
  """
  use Phoenix.LiveComponent

  attr(:node, :map, required: true)

  def render(assigns) do
    ~H"""
      <div class="flex-1 bg-zinc-900 py-4 px-2 h-100% rounded-lg border border-stone-900">
        <form class="flex flex-col gap-3">
          <div class="flex flex-col p-4 h-full gap-1 justify-center flex-1">
            <textarea
              type="text"
              id="processing_input"
              name="processing_input"
              phx-change="update_prompt"
              phx-target={@myself}
              phx-debounce="500"
              aria-label="disabled input"
              rows="5"
              class="
                box_input_inset_shadow disabledmb-6 text-gray-900 text-sm rounded-lg
                border-stone-900 block w-full p-4 cursor-not-allowed dark:text-gray-400"
            >Some test value goes here</textarea>
            <small class="text-gray-500 text-center pt-2 px-2">Explain what you would like AI to change or do with the input.</small>
            <small class="text-gray-500 text-center px-2">The result of the response will be able to be referenced using ::ai()</small>
          </div>

          <label class="flex items-center cursor-pointer px-2">
            <span class="flex-1 font-medium text-gray-900 dark:text-gray-300">Enable</span>
            <div>
              <input type="checkbox" phx-change="toggle_ai_enabled" checked={@node.enabled} value="" class="sr-only peer" />
              <div class="
                relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4
                peer-focus:ring-grey-300 dark:peer-focus:ring-zinc-800 rounded-full peer
                dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full
                peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px]
                after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5
                after:transition-all dark:border-gray-600 peer-checked:bg-green-700"></div>
            </div>
          </label>
        </form>
      </div>
    """
  end

  @doc """
    Here we handle the update to input processing
  """
  def handle_event("update_prompt", params, %{assigns: assigns} = socket) do
    %{"_target" => [item]} = params
    %{"_target" => _, ^item => text_value} = params

    # TODO: this needs to get persisted
    IO.inspect(text_value, label: "AI PROCESSING INPUT")
    # update_prompt()

    {:noreply,  socket}
  end

  @doc """
    Udpate the toggle state of if the prompt should run or not
  """
  def handle_event("toggle_ai_enabled", _, %{assigns: assigns} = socket) do
    node = assigns.node || false

    # case node do
    #   false -> {:noreply, socket}
    #   _ ->
    #     payload = %{"id" => node.id, "should_log" => !node.should_log}
    #     {_status, updated_node} = update_node(payload, node)
    #     socket =
    #       socket
    #       |> assign(:node, updated_node)
    #       |> assign(:should_log, updated_node.should_log || false)

    # {:noreply, socket}
    # end
    {:noreply, socket}
  end

  @doc """
    Update the prompt data that we assocoate with nodes
  """
  defp update_prompt(expression) do
    # case LeafNode.Repo.Expression.edit_expression(expression) do
    #   {:ok, _} -> :ok
    #   {:error, err} -> IO.inspect("There was a problem updating the expression: #{err}")
    # end

    :ok
  end
end
