defmodule LeafNodeWeb.Components.NodeLogs do
  @moduledoc """
  The base component to manage the node header section.
  """
  use Phoenix.LiveComponent
  alias LeafNodeWeb.Router.Helpers, as: Routes

  attr :logs, :list, required: true
  attr :node, :map, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grow bg-zinc-900 rounded-lg py-4 border border-stone-900 bg-grey-500 overflow-hidden">
      <div :if={!@node.should_log} class="p-4 mb-4 text-sm text-blue-800 rounded-lg bg-blue-50 dark:bg-gray-800 dark:text-blue-400" role="alert">
        Logs have been paused, logs won't be shown until settings have been changed above.
      </div>
      <div disabled={!@node.should_log} class={if !@node.should_log, do: "opacity-40", else: "opacity-100"} style="max-height: 500px; overflow-y: auto;">
        <%= if Enum.empty?(@logs) do %>
          <div class="px-4">No logs</div>
        <% else %>
          <ul class="divide-y divide-zinc-900 dark:border-zinc-900 px-2">
            <%= for item <- @logs do %>
              <li class="p-4 sm:p-4 cursor-pointer hover:bg-zinc-800 rounded-lg" phx-target={@myself} phx-click="view_log" phx-value-id={item.id}>
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
                      "text-xs font-medium me-2 px-2.5 py-0.5 rounded " <>
                      if item.status, do: "bg-green-100 dark:bg-green-700", else: "bg-red-100 dark:bg-red-700"
                    }>
                      <%= if item.status, do: "Success", else: "Failure" %>
                    </span>
                  </div>
                </div>
              </li>
            <% end %>
          </ul>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("view_log", %{"id" => log_id}, socket) do
    url = Routes.live_path(socket, LeafNodeWeb.LogDetailsLive, log_id)
    {:noreply, push_navigate(socket, to: url)}
  end
end
