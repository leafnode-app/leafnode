defmodule LeafNode.Servers.TriggerIntegration do
  @moduledoc """
    This is the integrations functions that get Triggered or executed
  """

  @doc """
    Based off the integration the functions that will take data and execute against it
  """
  def integration_action(type, %{user_id: user_id} = node, payload)
       when type === "google_send_mail" do
    %{
      "recipient" => recipient,
      "subject" => subject,
      "body" => body
    } = node.integration_settings

    token_details =
      LeafNode.Repo.OAuthToken.get_token(user_id, LeafNode.get_integration_type(type))

    %{email: email} = LeafNode.Accounts.get_user!(user_id)
    # call the function here
    # TODO: add other google services and integration functions here?
    {status, resp} =
      LeafNode.Integrations.Google.Mail.send_email(
        LeafNode.Repo.OAuthToken.refresh_token_check(token_details, :google),
        email,
        recipient,
        LeafNode.parse_node_input(subject, payload),
        LeafNode.parse_node_input(body, payload)
      )

    success_check = if status == :ok, do: true, else: false
    code = if success_check, do: 200, else: 500
    # async log
    # TODO: find a better result for the logs based off integration
    LeafNode.Servers.ExecutionServer.log_result(
      node,
      node,
      LeafNode.Utils.Helpers.http_resp(code, success_check, resp),
      success_check
    )
  end

  def integration_action(type, %{user_id: user_id} = node, payload)
       when type === "google_sheet_write" do
    %{
      "input" => input,
      "range_end" => range_end,
      "range_start" => range_start,
      "spreadsheet_id" => id,
      "tab" => _tab
    } = node.integration_settings

    token_details =
      LeafNode.Repo.OAuthToken.get_token(user_id, LeafNode.get_integration_type(type))

    # call the function here
    # TODO: add other google services and integration functions here?
    {status, resp} =
      LeafNode.Integrations.Google.Sheets.write_to_sheet(
        LeafNode.Repo.OAuthToken.refresh_token_check(token_details, :google),
        id,
        range_start <> ":" <> range_end,
        [LeafNode.parse_node_input(String.split(input, ","), payload)]
      )

    success_check = if status == :ok, do: true, else: false
    code = if success_check, do: 200, else: 500
    # async log
    # TODO: find a better result for the logs based off integration
    LeafNode.Servers.ExecutionServer.log_result(
      node,
      node,
      LeafNode.Utils.Helpers.http_resp(code, success_check, resp),
      success_check
    )
  end

  def integration_action(type, %{user_id: user_id} = node, payload)
       when type === "notion_page_write" do
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
        LeafNode.parse_node_input(content, payload)
      )

    success_check = if status == :ok, do: true, else: false
    code = if success_check, do: 200, else: 500
    # async log
    # TODO: find a better result for the logs based off integration
    LeafNode.Servers.ExecutionServer.log_result(
      node,
      node,
      LeafNode.Utils.Helpers.http_resp(code, success_check, resp),
      success_check
    )
  end
end
