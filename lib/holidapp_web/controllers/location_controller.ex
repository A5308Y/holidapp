defmodule HolidappWeb.LocationController do
  use HolidappWeb, :controller

  alias Holidapp.HolidayRequest
  alias Holidapp.HolidayRequest.Location

  action_fallback HolidappWeb.FallbackController

  def create(conn, %{"location" => location_params}) do
    with {:ok, %Location{} = location} <- HolidayRequest.create_location(location_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.location_path(conn, :show, location))
      |> render("show.json", location: location)
    end
  end

  def show(conn, %{}) do
    conn = fetch_session(conn, :current_user)
    current_user = get_session(conn, :current_user)

    render(conn, "show.json", location: HolidayRequest.get_user_location!(current_user.id))
  end

  def update(conn, %{"id" => id, "location" => location_params}) do
    location = HolidayRequest.get_location!(id)

    with {:ok, %Location{} = location} <-
           HolidayRequest.update_location(location, location_params) do
      render(conn, "show.json", location: location)
    end
  end

  def delete(conn, %{"id" => id}) do
    location = HolidayRequest.get_location!(id)

    with {:ok, %Location{}} <- HolidayRequest.delete_location(location) do
      send_resp(conn, :no_content, "")
    end
  end
end
