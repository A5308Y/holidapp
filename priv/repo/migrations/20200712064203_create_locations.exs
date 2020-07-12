defmodule Holidapp.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :state_shorthand, :string
      add :city_name, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:locations, [:user_id])
  end
end
