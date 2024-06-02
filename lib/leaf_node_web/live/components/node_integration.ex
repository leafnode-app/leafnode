defmodule LeafNodeWeb.Components.NodeIntegration do
  @moduledoc """
    General node side effect that would be expected to run
  """
  use Phoenix.LiveComponent
  alias LeafNodeWeb.Router.Helpers, as: Routes
  import LeafNode.Repo.Node, only: [integration_types: 0]

  # TODO: THIS NEEDS TO BE MORE GENERIC TO MANAGE THE DIFFERENT TYPES FOR EACH INTEGRATION SETTINGS

  def update(assigns, socket) do
    integration_settings = assigns.node.integration_settings || %{}

    IO.inspect(integration_settings)
    {:ok,
     socket
     |> assign(:show_modal, false)
     |> assign(:node, assigns.node)
     |> assign(:input, Map.get(integration_settings, "input"))
     |> assign(:type, Map.get(integration_settings, "type"))
     |> assign(:has_oauth, Map.get(integration_settings, "has_oauth"))
     |> assign(:form_opts, %{
       integrations: integration_types()
     })}
  end

  def render(assigns) do
    ~H"""
    <div class="flex-1 bg-zinc-900 h-100% py-4 px-2 rounded-lg border border-stone-900">
      <%= if @type === "none" do %>
        <div class="flex flex-col p-4 h-full gap-1 justify-center flex-1">
          <div class="node_block_wrapper box_input_inset_shadow cursor-pointer" phx-target={@myself} phx-click="open_modal">
            click here to add integration
          </div>
        </div>
      <% else %>
        <div>
          <div class="flex flex-col p-4 h-full gap-1 justify-center flex-1">
            <%= if @has_oauth do %>
              <div class="node_block_wrapper box_input_inset_shadow cursor-pointer" phx-target={@myself} phx-click="open_modal">
                <%!-- <pre class="text-blue-300"> --%>
                  <%= @input %> (<%= @type %>)
                <%!-- </pre> --%>
              </div>
            <% else %>
              <div class="node_block_wrapper box_input_inset_shadow cursor-pointer" phx-target={@myself} phx-click="oauth_access">
                <div>click here to grant Integration (<%= empty_check(@type, "type") %>) permissions</div>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>

      <%= if @show_modal do %>
        <div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
          <div class="bg-zinc-800 p-6 rounded-lg shadow-lg w-1/2 max-w-lg">
            <h2 class="text-2xl text-white mb-4">Integration</h2>
            <form phx-submit="update_integration">
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-300 mb-2">Type:</label>
                <select name="type"
                  phx-change="change_type"
                  phx-target={@myself}
                  class="focus:outline-none box_input_inset_shadow text-gray-900
                    text-sm rounded-lg border-stone-900 block w-full p-4 dark:text-gray-400">
                  <%= for integration <- @form_opts.integrations do %>
                    <option value={integration} selected={integration == @type}><%= integration %></option>
                  <% end %>
                </select>
                <small class="text-gray-500">Select the type of integration.</small>
              </div>

              <%!-- Input in order to store against the settings - this needs to be schema settings for type --%>
              <%= if @type !== "none" do %>
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
              <% end %>

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

  def handle_event("oauth_access", _params, socket) do
    # TODO we need to change this
    {:noreply, redirect(socket, to: "/auth/request/#{socket.assigns.node.id}")}
  end

  def handle_event("open_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  defp empty_check(value, type) when value == "" do
    "[#{type}]"
  end

  defp empty_check(value, _type) do
    value
  end

  def handle_event("change_type", %{"type" => type}, socket) do
    {:noreply, assign(socket, :type, type)}
  end
end
