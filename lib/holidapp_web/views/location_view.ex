defmodule HolidappWeb.LocationView do
  use HolidappWeb, :view
  alias HolidappWeb.LocationView

  def render("index.json", %{locations: locations}) do
    %{data: render_many(locations, LocationView, "location.json")}
  end

  def render("show.json", %{location: location}) do
    %{data: render_one(location, LocationView, "location.json")}
  end

  def render("location.json", %{location: location}) do
    %{
      state_shorthand: location.state_shorthand,
      city_name: location.city_name
    }
  end
end
