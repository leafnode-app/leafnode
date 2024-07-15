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
  token: "",
  model: "",
  completions_url: ""

# Cloak configuration
config :leaf_node, LeafNode.Cloak.Vault,
  json_library: Jason,
  ciphers: [
    # In AES.GCM, it is important to specify 12-byte IV length for
    # interoperability with other encryption software. See this GitHub issue
    # for more details: https://github.com/danielberkompas/cloak/issues/93
    #
    # In Cloak 2.0, this will be the default iv length for AES.GCM.
    # ---
    # For the key we need to take 32 random strongly randomised bytes, encode it so we dont have escaped or special characters
    # 32 |> :crypto.strong_rand_bytes() |> Base.encode64()
    aes_gcm:
      {Cloak.Ciphers.AES.GCM,
       tag: "AES.GCM.V1", key: Base.decode64!("SOME KEY")}
  ]

config :leaf_node, LeafNode.Hashed.HMAC,
  algorithm: :sha512,
  # 32 |> :crypto.strong_rand_bytes() |> Base.encode64()
  secret: "secret"
