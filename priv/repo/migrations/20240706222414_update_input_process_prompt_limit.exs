defmodule LeafNode.Repo.Migrations.UpdateInputProcessPromptLimit do
  use Ecto.Migration

  def change do
    alter table(:input_processes) do
      modify :value, :text
    end
  end
end
