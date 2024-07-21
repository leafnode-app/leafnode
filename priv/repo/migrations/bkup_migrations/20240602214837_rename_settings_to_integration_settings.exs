defmodule LeafNode.Repo.Migrations.RenameSettingsToIntegrationSettings do
  use Ecto.Migration

  def change do
    rename table("nodes"), :settings, to: :integration_settings
  end
end
