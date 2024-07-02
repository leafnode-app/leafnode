# This is the general local secrets file used and should NOT be committed
import Config

# Google Client Secret
config :leaf_node, :client_secrets_google,
  auth_provider_x509_cert_url: "",
  auth_uri: "",
  client_id: "",
  client_secret: "",
  project_id: "",
  redirect_uris: [
    ""
  ],
  token_uri: "",
  scopes_list: [
    "",
    ""
  ]

# Notion Client Secret
config :leaf_node, :client_secrets_notion,
  auth_uri: "",
  client_id: "",
  client_secret: "",
  response_type: "",
  redirect_uri: "",
  owner: ""

# Open AI token
config :leaf_node, :open_ai,
  token: System.get_env("OPEN_AI_TOKEN"),
  model: System.get_env("OPEN_AI_MODEL"),
  completions_url: ""
