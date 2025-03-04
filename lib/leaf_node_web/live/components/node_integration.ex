defmodule LeafNodeWeb.Components.NodeIntegration do
  @moduledoc """
    General node side effect that would be expected to run
  """
  use Phoenix.LiveComponent
  import LeafNodeWeb.Gettext
  import LeafNode.Repo.Node, only: [integrations_list: 0]
  require Logger

  # @google "google"
  @notion "notion"

  # TODO: THIS NEEDS TO BE MORE GENERIC TO MANAGE THE DIFFERENT TYPES FOR EACH INTEGRATION SETTINGS
  def update(assigns, socket) do
    integration_settings = assigns.node.integration_settings || %{}

    {:ok,
     socket
     |> assign(:current_user, assigns.current_user)
     |> assign(:show_modal, false)
     |> assign(:node, assigns.node)
     |> assign(:input, Map.get(integration_settings, "input"))
     |> assign(:service_type, Map.get(integration_settings, "type"))
     |> assign(:has_oauth, Map.get(integration_settings, "has_oauth"))
     |> assign(:integration_settings, integration_settings)
     |> assign(:form_opts, %{
       integrations: integrations_list()
     })}
  end

  def render(assigns) do
    ~H"""
    <div class="border border-gray-700 bg-zinc-900 rounded-lg py-4 px-2">
      <%
        integration_action = String.split(@service_type, "_") |> Enum.at(0)
        integration_action_str = String.capitalize(integration_action) |> String.split("_") |> Enum.at(0)
      %>

      <%!-- TODO: need to have a separate things for connecting integrations that could be next to it? --%>
      <div class="flex flex-col p-4 h-full gap-1 justify-center flex-1">
        <div class="node_block_wrapper box_input_inset_shadow cursor-pointer mb-4 bg-zinc-900 hover:bg-zinc-800" phx-target={@myself} phx-click="open_modal">
          <p class="text-gray-500">
            <%= if @service_type === "none" do %>
              Add integration
            <% else %>
              click to view <%= @service_type %> settings
            <% end %>
          </p>
        </div>

        <%!-- We make sure the user selected an integration before we request to have the user connect --%>
        <%= if @service_type !== "none" do %>
          <div class="flex align-items justify-center gap-2">
            <%= if @has_oauth do %>
              <button
                phx-click="oauth_access"
                phx-value-oauth-type={integration_action}
                phx-target={@myself}
                class={"bg-yellow-700 hover:bg-yellow-600 py-2 px-4 text-sm rounded transition duration-200 ease-in-out w-auto self-center"}
              >
                Connect Pages
              </button>
              <button
                phx-click="oauth_disconnect"
                phx-value-oauth-type={integration_action}
                phx-target={@myself}
                class={"bg-red-700 hover:bg-red-600 py-2 px-4 text-sm rounded transition duration-200 ease-in-out w-auto self-center"}
              >
                Disconnect <%= integration_action_str %>
              </button>
            <% else %>
              <button
                phx-click="oauth_access"
                phx-value-oauth-type={integration_action}
                phx-target={@myself}
                disabled={@has_oauth}
                class={"bg-blue-700 hover:bg-blue-600 py-2 px-4 text-sm rounded transition duration-200 ease-in-out w-auto self-center"}
              >
                Connect <%= integration_action_str %>
              </button>
            <%= end %>
          </div>
        <% end %>
      </div>
      <%= if @has_oauth do %>
        <div class="border border-gray-700 flex items-center mt-2 gap-2 rounded p-3 bg-zinc-800">
          <div>
            <p class="text-sm text-gray-300"><%= gettext("Disconnect or connect more pages - make sure page id links to a page that the app has access to.") %></p>
          </div>
        </div>
      <% else %>
      <div class="premium-border flex items-center mt-2 gap-2 rounded p-3 bg-zinc-800">
        <div>
          <p class="text-sm text-gray-300"><%= gettext("Connect Notion Pages and then open modal to add the id of the page of an linked page.") %></p>
        </div>
      </div>
      <% end %>

      <%= if @show_modal do %>
        <div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
          <div class="border border-gray-700 bg-zinc-800 p-6 rounded-lg shadow-lg w-1/2 max-w-lg">
            <h2 class="text-2xl text-white mb-4">Integration</h2>
            <form phx-submit="update_integration">
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-300 mb-2">Type:</label>
                <select name="type"
                  phx-change="change_type"
                  phx-target={@myself}
                  class="focus:outline-none box_input_inset_shadow text-gray-900
                    text-sm rounded-lg border-stone-900 block w-full p-4 dark:text-gray-400">
                  <%= for {action, _} <- @form_opts.integrations do %>
                    <option value={action} selected={action == @service_type}><%= action %></option>
                  <% end %>
                </select>
                <small class="text-gray-500">Select the type of integration.</small>
              </div>

              <%!-- Input in order to store against the settings - this needs to be schema settings for type --%>
              <%= if @service_type !== "none" do %>
                <div class="mb-4">
                  <%= for {id, title, type, desc} <- render_integration_settings(@service_type) do %>
                    <div class="py-2">
                      <label class="block text-sm font-medium text-gray-300 text-xs"><%= title %></label>
                      <span class="text-gray-500 pb-5 text-xs"><%= desc %></span>

                      <%= if type === "textarea" do %>
                      <textarea
                        type="text"
                        name={id}
                        phx-target={@myself}
                        rows="5"
                        class="
                          box_input_inset_shadow disabledmb-6 text-gray-900 text-sm rounded-lg
                          border-stone-900 block w-full p-4 dark:text-gray-400"
                      ><%= @integration_settings[id] %></textarea>
                      <% else %>
                        <input
                          autocomplete="false"
                          type={type}
                          name={id}
                          value={@integration_settings[id]}
                          phx-target={@myself}
                          class="focus:outline-none box_input_inset_shadow
                            text-gray-900 text-sm rounded-lg border-stone-900 block w-full p-4 dark:text-gray-400" />
                      <% end %>
                    </div>
                  <% end %>
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

  def handle_event("oauth_access", %{"oauth-type" => oauth_type}, socket) do
    case oauth_type do
      @notion ->
        {:noreply, redirect(socket, to: "/auth/notion/request/#{socket.assigns.node.id}")}

      # @google ->
      #   {:noreply, redirect(socket, to: "/auth/google/request/#{socket.assigns.node.id}")}

      _ ->
        Logger.error("Attempt to try and auth an integration that is not part of the list")
        {:noreply, socket}
    end
  end

  def handle_event("oauth_disconnect", %{ "oauth-type" => oauth_type }, socket) do
    %{ node: node, current_user: current_user} = socket.assigns || %{}
    # Get the token id relative to the type
    {status, _} = LeafNode.Repo.OAuthToken.remove_token(current_user.id, oauth_type)
    # TODO: Update the oauth but we need to make sure the transaction is done as well removing the integration
    socket = case status do
      :ok ->
        # We might need a check here based off the status in case this fails
        LeafNode.Repo.Node.edit_node(%{ "id" => node.id, "integration_settings" => %{ "has_oauth" => false} })
        assign(socket, has_oauth: false)
      _ ->
        socket
    end

    {:noreply, socket}
  end

  def handle_event("open_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  def handle_event("change_type", %{"type" => type}, socket) do
    integration_type = String.split(type, "_") |> Enum.at(0)
    node = socket.assigns.node
    user_id = node.user_id

    case LeafNode.Repo.OAuthToken.get_token(user_id, integration_type) do
      nil ->
        # user has no take for the selected integration
        socket =
          socket
          |> assign(:service_type, type)
          |> assign(:has_oauth, false)

        {:noreply, socket}

      _ ->
        {:noreply, assign(socket, :service_type, type) |> assign(:has_oauth, true) }
    end
  end

  # The settings to render for the integration
  # TODO: we need to make the items part of the enum
  def render_integration_settings(service_type) do
    case service_type do
      "notion_page_read" ->
        LeafNode.Integrations.Notion.Pages.input_info()
    end
  end
end
