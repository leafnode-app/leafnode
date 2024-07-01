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
# import Ecto.Query, only: [from: 2]

# TOOD: add the system user

# TOOD: add the missing augmentations

# query = Ecto.Query.from(n in LeafNode.Schemas.Node, select: n.id)
# LeafNode.Repo.all(query) |> Enum.each(fn node_id ->
#   LeafNode.Repo.Augmentation.create_augment(node_id, "ai", false, "")
# end)
