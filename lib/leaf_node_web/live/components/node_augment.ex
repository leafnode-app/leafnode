defmodule LeafNodeWeb.Components.NodeAugment do
  @moduledoc """
    The details around interacting with the node and controls to set logging and node availibility
  """
  use Phoenix.LiveComponent

  attr(:node, :map, required: true)
  attr(:augment, :map, required: true)

  def render(assigns) do
    ~H"""
      <div class="flex-1 bg-zinc-900 py-4 px-2 h-100% rounded-lg border border-stone-900">
        <form class="flex flex-col gap-3">
          <div class="flex flex-col p-4 h-full justify-center flex-1">
            <textarea
              type="text"
              id="augmentation_input"
              name="augmentation_input"
              phx-change="update_prompt"
              phx-target={@myself}
              phx-debounce="500"
              aria-label="disabled input"
              rows="5"
              class="
                box_input_inset_shadow disabledmb-6 text-gray-900 text-sm rounded-lg
                border-stone-900 block w-full p-4 dark:text-gray-400"
            ><%= @augment.value %></textarea>
            <small class="text-gray-500 text-center pt-2 px-2">Explain what you would like AI to change or do with the input.</small>
          </div>

          <label class="flex items-center cursor-pointer px-2">
            <span class="flex-1 font-medium text-gray-900 dark:text-gray-300">Enable</span>
            <div>
              <!-- Hidden input to represent the "off" state -->
              <input type="hidden" name="augmentation_toggle" value="off" />
              <input
                type="checkbox"
                id="augmentation_toggle"
                name="augmentation_toggle"
                phx-change="toggle_ai_enabled"
                phx-target={@myself}
                checked={@augment.enabled}
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
    Here we handle the update to input augmentation
  """
  def handle_event("update_prompt", params, %{assigns: %{ augment: augment } = assigns} = socket) do
    # Might get validation errors that we need to return
    update_prompt(%{
      "id" => augment.id,
      "value" => form_item_name_value(params)
    })

    {:noreply,  socket}
  end

  @doc """
    Update the toggle state of if the prompt should run or not
  """
  def handle_event("toggle_ai_enabled", params, %{assigns: %{ augment: augment } = _assigns} = socket) do
    enabled_state = if form_item_name_value(params) == "on", do: true, else: false
    update_prompt(%{
      "id" => augment.id,
      "enabled" => enabled_state
    })
    {:noreply, socket}
  end

  @doc """
    Update the prompt data that we associate with nodes
  """
  defp update_prompt(augment) do
    LeafNode.Repo.Augmentation.edit_augment(augment)
  end

  # basic for now but the value of the form id element
  defp form_item_name_value(params) do
    %{"_target" => [item]} = params
    %{"_target" => _, ^item => text_value} = params
    text_value
  end
end
