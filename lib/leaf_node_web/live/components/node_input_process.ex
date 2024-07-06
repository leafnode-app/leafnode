defmodule LeafNodeWeb.Components.NodeInputProcess do
  @moduledoc """
    The details around interacting with the node and controls to set logging and node availibility
  """
  use Phoenix.LiveComponent

  attr(:node, :map, required: true)
  attr(:input_process, :map, required: true)

  def render(assigns) do
    ~H"""
      <div class="flex-1 bg-zinc-900 py-4 px-2 h-100% rounded-lg border border-stone-900">
        <form class="flex flex-col gap-3">
          <div class="flex flex-col p-4 h-full justify-center flex-1">
            <textarea
              type="text"
              id="process_input"
              name="process_input"
              phx-change="update_prompt"
              phx-target={@myself}
              phx-debounce="500"
              aria-label="disabled input"
              rows="5"
              class="
                box_input_inset_shadow disabledmb-6 text-gray-900 text-sm rounded-lg
                border-stone-900 block w-full p-4 dark:text-gray-400"
            ><%= @input_process.value %></textarea>
            <small class="text-gray-500 text-center pt-2 px-2">Explain what you would like AI to change or do with the input.</small>
            <small class="text-gray-500 text-center pt-2 px-2">To reference the AI processed data, use [[input_process.data]] in your inputs</small>
          </div>

          <label class="flex items-center cursor-pointer px-2">
            <span class="flex-1 font-medium text-gray-900 dark:text-gray-300">Enable AI Processing</span>
            <div>
              <!-- Hidden input to represent the "off" state -->
              <input type="hidden" name="aug_enable_toggle" value="off" />
              <input
                type="checkbox"
                id="aug_enable_toggle"
                name="aug_enable_toggle"
                phx-change="toggle_ai_enabled"
                phx-target={@myself}
                checked={@input_process.enabled}
                class="sr-only peer"
              />
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
            <span class="flex-1 font-medium text-gray-900 dark:text-gray-300">Run Async</span>
            <div>
              <!-- Hidden input to represent the "off" state -->
              <input type="hidden" name="aug_resp_toggle" value="off" />
              <input
                type="checkbox"
                id="aug_resp_toggle"
                name="aug_resp_toggle"
                phx-change="toggle_ai_response"
                phx-target={@myself}
                checked={@input_process.async}
                class="sr-only peer"
              />
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
  def handle_event("update_prompt", params, %{assigns: %{ input_process: input_process } = _assigns} = socket) do
    # Might get validation errors that we need to return
    update_prompt(%{
      "id" => input_process.id,
      "value" => form_item_name_value(params)
    })

    {:noreply,  socket}
  end

  @doc """
    Update the toggle state of if the prompt should run or not
  """
  def handle_event("toggle_ai_enabled", params, %{assigns: %{ input_process: input_process } = _assigns} = socket) do
    enabled_state = if form_item_name_value(params) == "on", do: true, else: false
    update_prompt(%{
      "id" => input_process.id,
      "enabled" => enabled_state
    })
    {:noreply, socket}
  end

  @doc """
    Update the toggle state of if the prompt should run or not
  """
  def handle_event("toggle_ai_response", params, %{assigns: %{ input_process: input_process } = _assigns} = socket) do
    enabled_state = if form_item_name_value(params) == "on", do: true, else: false
    update_prompt(%{
      "id" => input_process.id,
      "async" => enabled_state
    })
    {:noreply, socket}
  end

  @doc """
    Update the prompt data that we associate with nodes
  """
  defp update_prompt(input_process) do
    LeafNode.Repo.InputProcess.edit_input_process(input_process)
  end

  # basic for now but the value of the form id element
  defp form_item_name_value(params) do
    %{"_target" => [item]} = params
    %{"_target" => _, ^item => text_value} = params
    text_value
  end
end
