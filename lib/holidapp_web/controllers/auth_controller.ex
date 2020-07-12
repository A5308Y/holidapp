defmodule HolidappWeb.AuthController do
  use HolidappWeb, :controller
  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    user_params = %{
      token: auth.credentials.token,
      email: auth.info.email,
      provider: params["provider"]
    }

    changeset = Holidapp.Accounts.User.changeset(%Holidapp.Accounts.User{}, user_params)
    signin(conn, changeset)
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "You have been signed in.")
        |> put_session(:current_user, user)
        |> redirect(to: "/")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in.")
        |> redirect(to: "/")
    end
  end

  defp insert_or_update_user(changeset) do
    case Holidapp.Repo.get_by(Holidapp.Accounts.User, email: changeset.changes.email) do
      nil ->
        Holidapp.Repo.insert(changeset)

      user ->
        {:ok, user}
    end
  end
end
