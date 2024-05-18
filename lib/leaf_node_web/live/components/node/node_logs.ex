defmodule LeafNodeWeb.Components.NodeLogs do
  @moduledoc """
    The base component to manage the node header seciton
  """
  use Phoenix.LiveComponent

  attr :logs, :list, required: true

  def render(assigns) do
    ~H"""
      <div class="grow bg-zinc-900 rounded-lg p-4 w-full md:w-80 border border-stone-900 h-full bg-grey-500 p-1">
        <%!-- Logs --%>
        <%= if Enum.empty?(@logs) do%>
          No logs
        <%= else%>
          <ul class="divide-y divide-zinc-900 dark:border-zinc-900 px-2">
            <%= for item <- @logs do %>
              <li class="py-2 sm:py-2">
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
                    "text-xs font-medium me-2 px-2.5 py-0.5 rounded" <>
                    if item.status, do: "bg-green-100 dark:bg-green-700", else: "bg-red-100 dark:bg-red-700"
                  }>
                    <%= item.status %>
                  </span>
                  </div>
                </div>
              </li>
            <% end %>
          </ul>
        <%= end%>
      </div>
    """
  end
end
