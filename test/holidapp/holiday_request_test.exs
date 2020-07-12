defmodule Holidapp.HolidayRequestTest do
  use Holidapp.DataCase

  alias Holidapp.HolidayRequest

  describe "locations" do
    alias Holidapp.HolidayRequest.Location

    @valid_attrs %{city_name: "some city_name", state_shorthand: "some state_shorthand"}
    @update_attrs %{city_name: "some updated city_name", state_shorthand: "some updated state_shorthand"}
    @invalid_attrs %{city_name: nil, state_shorthand: nil}

    def location_fixture(attrs \\ %{}) do
      {:ok, location} =
        attrs
        |> Enum.into(@valid_attrs)
        |> HolidayRequest.create_location()

      location
    end

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert HolidayRequest.list_locations() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert HolidayRequest.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      assert {:ok, %Location{} = location} = HolidayRequest.create_location(@valid_attrs)
      assert location.city_name == "some city_name"
      assert location.state_shorthand == "some state_shorthand"
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = HolidayRequest.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()
      assert {:ok, %Location{} = location} = HolidayRequest.update_location(location, @update_attrs)
      assert location.city_name == "some updated city_name"
      assert location.state_shorthand == "some updated state_shorthand"
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = HolidayRequest.update_location(location, @invalid_attrs)
      assert location == HolidayRequest.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = HolidayRequest.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> HolidayRequest.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = HolidayRequest.change_location(location)
    end
  end
end
