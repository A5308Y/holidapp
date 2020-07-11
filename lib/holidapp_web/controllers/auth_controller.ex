defmodule HolidappWeb.AuthController do
  use HolidappWeb, :controller
  plug Ueberauth

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
    |> redirect(external: root_url(conn))
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "You have been signed in.")
        |> put_session(:user_id, user.id)
        |> redirect(external: root_url(conn))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in.")
        |> redirect(external: root_url(conn))
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

  defp root_url(conn) do
    host =
      conn.host
      |> String.split(".")
      |> Enum.at(1)

    if conn.port do
      "#{conn.scheme}://#{host}:#{conn.port}"
    else
      "#{conn.scheme}://#{host}"
    end
  end
end
