defmodule LeafNode.Servers.TriggerIntegration do
  @moduledoc """
    This is the integrations functions that get Triggered or executed
  """

  @doc """
    Based off the integration the functions that will take data and execute against it
  """
  # TODO: we need to read from Notion here, so setup to read docs and the associated functions
  def integration_action(type, %{user_id: user_id} = node) when type === "notion_page_read" do
    %{ "page_id" => page_id } = node.integration_settings

    case LeafNode.Integrations.Notion.Pages.read_content(
      page_id,
      LeafNode.Repo.OAuthToken.get_token(user_id, LeafNode.get_integration_type(type)).access_token
    ) do
      {:ok, data} ->
        {:ok, data}
      _ ->
        {:error, "There was an error getting the Notion page"}
    end
  end

  # TODO: add the fetching of notion integration functions here
  def integration_action(type, _node, _payload) when type === "none" do
    :none
  end
end
