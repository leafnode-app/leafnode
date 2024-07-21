# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LeafNode.Repo.insert!(%LeafNode.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# here we can add the initial root user details to the system
import Ecto.Query, only: [from: 2]

# add User needed extension tokens
query = from(n in LeafNode.Accounts.User, select: n.id)
LeafNode.Repo.all(query) |> Enum.each(fn user_id ->
  user_token = LeafNode.Repo.ExtensionToken.get_token_by_user(user_id)
  if is_nil(user_token) do
    LeafNode.Repo.ExtensionToken.generate_token(user_id, UUID.uuid4())
  end
end)
