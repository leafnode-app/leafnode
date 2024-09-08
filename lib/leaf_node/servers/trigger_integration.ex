defmodule LeafNode.Servers.TriggerIntegration do
  @moduledoc """
    This is the integrations functions that get Triggered or executed
  """

  @doc """
    Based off the integration the functions that will take data and execute against it
  """

  # TODO: we need to read from Notion here, so setup to read docs and the associated functions
  def integration_action(type, %{user_id: user_id} = node, payload)
       when type === "notion_page_read" do
    %{
      "page_id" => page_id,
      "content" => content
    } = node.integration_settings

    token_details =
      LeafNode.Repo.OAuthToken.get_token(user_id, LeafNode.get_integration_type(type))

    {status, resp} =
      LeafNode.Integrations.Notion.Pages.append_content(
        page_id,
        token_details.access_token,
        LeafNode.Core.Interpolator.interpolate_string(content, payload)
      )

    success_check = if status == :ok, do: true, else: false
    code = if success_check, do: 200, else: 500
    # async log
    # TODO: find a better result for the logs based off integration
    LeafNode.log_result(
      node,
      payload,
      LeafNode.Utils.Helpers.http_resp(code, success_check, resp),
      success_check
    )
  end

  # TODO: add the fetching of notion integration functions here

  def integration_action(type, _node, _payload) when type === "none" do
    :none
  end
end
