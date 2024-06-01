defmodule LeafNodeWeb.Components.NodeSettings do
  @moduledoc """
  General node conditions and side effects that need to be run.
  """
  use Phoenix.LiveComponent
  import LeafNode.Repo.Node, only: [expression_types: 0, condition_types: 0]

  def update(assigns, socket) do
    expression = assigns.expression || %{}

    {:ok,
      socket
      |> assign(:id, Map.get(expression, :id))
      |> assign(:input, Map.get(expression, :input, ""))
      |> assign(:cond, Map.get(expression, :expression, ""))
      |> assign(:value, Map.get(expression, :value, ""))
      |> assign(:type, Map.get(expression, :type, ""))
      |> assign(:node_id, Map.get(expression, :node_id))
      |> assign(:show_modal, false)
      |> assign(:form_opts, %{
          expressions_types: expression_types(),
          cond_types: condition_types()
        })
    }
  end

  def render(assigns) do
    ~H"""
    <div class="flex-1 bg-zinc-900 h-100% py-4 px-2 rounded-lg border border-stone-900">
      <div>
        <div class="flex flex-col p-4 h-full gap-1 justify-center flex-1">
          <div class="node_block_wrapper box_input_inset_shadow cursor-pointer" phx-target={@myself} phx-click="open_modal">
            <pre class="px-1 text-orange-300">
            when :: <%= empty_check(@input, "input") %> <%= empty_check(@cond, "condition") %> <%= empty_check(@value, "value") %> <%= "(type: #{empty_check(@type, "type")})" %> </pre>
          </div>
          <small class="text-gray-500 pt-2 px-2">Select the box above to start adding logic to compare against based on the expected payload</small>
        </div>
      </div>

      <%= if @show_modal do %>
        <div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
          <div class="bg-zinc-800 p-6 rounded-lg shadow-lg w-1/2 max-w-lg">
            <h2 class="text-2xl text-white mb-4">Add Condition</h2>
            <form phx-submit="save_condition" phx-target={@myself}>
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-300 mb-2">Input:</label>
                <input
                  autocomplete="false"
                  type="text"
                  name="input"
                  value={@input}
                  phx-target={@myself}
                  class="focus:outline-none box_input_inset_shadow
                    text-gray-900 text-sm rounded-lg border-stone-900 block w-full p-4 dark:text-gray-400" />
                <small class="text-gray-500">Specify the input field to be checked. Check logs based on expected input using dot.notation.for.selection</small>
              </div>
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-300 mb-2">Expression:</label>
                <select name="expression"
                  class="focus:outline-none box_input_inset_shadow
                    text-gray-900 text-sm rounded-lg border-stone-900
                    block w-full p-4 dark:text-gray-400">
                  <%= for expr <- @form_opts.expressions_types do %>
                    <option value={expr} selected={expr == @cond}><%= expr %></option>
                  <% end %>
                </select>
                <small class="text-gray-500">Choose the condition expression.</small>
              </div>
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-300 mb-2">Type:</label>
                <select name="type"
                  phx-change="change_type"
                  phx-target={@myself}
                  class="focus:outline-none box_input_inset_shadow text-gray-900
                    text-sm rounded-lg border-stone-900 block w-full p-4 dark:text-gray-400">
                  <%= for cond_type <- @form_opts.cond_types do %>
                    <option value={cond_type} selected={cond_type == @type}><%= cond_type %></option>
                  <% end %>
                </select>
                <small class="text-gray-500">Select the type of value.</small>
              </div>
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-300 mb-2">Value:</label>
                <%= if @type == "boolean" do %>
                  <input type="hidden" name="value" value={@value} />
                  <div class="flex items-center p-4 bg-zinc-700 rounded-md cursor-pointer" phx-click="toggle_boolean" phx-target={@myself}>
                    <input type="checkbox"
                      name="value"
                      class="focus:outline-none text-gray-900
                        text-sm rounded-lg border-stone-900" checked={@value == "true"} />
                    <span class="ml-3 text-gray-300">True</span>
                  </div>
                  <small class="text-gray-500">Toggle to set the boolean value.</small>
                <% else %>
                  <input auto-complete="false"
                    type="text"
                    name="value"
                    value={@value} class="focus:outline-none box_input_inset_shadow text-gray-900
                      text-sm rounded-lg border-stone-900 block w-full p-4 dark:text-gray-400" />
                  <small class="text-gray-500">Enter the value to compare against.</small>
                <% end %>
              </div>
              <div class="flex justify-end gap-2">
                <button type="submit" phx-target={@myself} class="px-4 py-2 bg-blue-600 text-white rounded-md">Save</button>
                <button type="button" phx-target={@myself} phx-click="close_modal" class="px-4 py-2 bg-gray-600 text-white rounded-md">Cancel</button>
              </div>
            </form>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("open_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  def handle_event("save_condition", %{"input" => input, "expression" => expression, "value" => value, "type" => type}, socket) do
    IO.inspect(type, label: "TYPE")
    IO.inspect(value, label: "BOOLEAN")
    value = if type == "boolean", do: if(value == "on", do: "true", else: "false"), else: value
    updated_expression = %{
      "id" => socket.assigns.id,
      "input" => input,
      "expression" => expression,
      "value" => value,
      "type" => type,
      "node_id" => socket.assigns.node_id
    }
    update_expression(updated_expression)

    {:noreply,
     socket
     |> assign(:cond, expression)
     |> assign(:input, input)
     |> assign(:value, value)
     |> assign(:type, type)
     |> assign(:show_modal, false)}
  end

  def handle_event("change_type", %{"type" => type}, socket) do
    {:noreply, assign(socket, :type, type)}
  end

  def handle_event("toggle_boolean", _params, socket) do
    value = if socket.assigns.value == "true", do: "false", else: "true"
    {:noreply, assign(socket, :value, value)}
  end

  defp empty_check(value, type) when value == "" do
    "[#{type}]"
  end
  defp empty_check(value, _type) do
    value
  end

  defp update_expression(expression) do
    case LeafNode.Core.Expression.edit_expression(expression) do
      {:ok, _} -> :ok
      {:error, err} -> IO.inspect("There was a problem updating the expression: #{err}")
    end
  end
end
