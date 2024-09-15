defmodule LeafNode.Client.MsgServer do
  @moduledoc """
  HTTP client used to make requests to MsgServer application
  """
  use Tesla, only: [:post]

  plug Tesla.Middleware.BaseUrl, config(:msg_service).host
  plug Tesla.Middleware.Headers, [{"content-type", "application/json"}, {"x-api-key", config(:msg_service).app_key}]
  plug Tesla.Middleware.JSON

  @doc """
  Make a POST request to the given service
  """
  @spec post(Tesla.Env.url(), Tesla.Env.body()) :: Tesla.Env.result()
  def post(path, params) do
    post(path, params)
  end

  # Configuration for internal API services calls against main application
  def config do
    Application.get_env(:leaf_node, :internal_services)
  end
  def config(key) do
    config()[key]
  end
end
