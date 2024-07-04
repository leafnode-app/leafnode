defmodule LeafNode.Repo do
  use Ecto.Repo,
    otp_app: :leaf_node,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query

  @doc """
  Limit the number of items per table so we stay within a range
  """
  def enforce_limit(table, limit, should_delete \\ true) do
    query = from(t in table, order_by: [asc: t.inserted_at])

    entries = __MODULE__.all(query)

    if length(entries) > limit do
      entries_to_delete = entries |> Enum.take(length(entries) - limit)
      if should_delete do
        entries_to_delete |> Enum.each(&__MODULE__.delete!/1)
      else
        {:error, "limit reached, unable to add"}
      end
    else
      :ok
    end
  end
end
