defmodule Holidapp.HolidayRequest.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :city_name, :string
    field :state_shorthand, :string
    belongs_to :user, EctoAssoc.User

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:state_shorthand, :city_name])
    |> validate_required([:state_shorthand, :city_name])
  end
end
