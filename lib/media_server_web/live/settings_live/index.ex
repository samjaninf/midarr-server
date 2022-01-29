defmodule MediaServerWeb.SettingsLive.Index do
  use MediaServerWeb, :live_view

  alias MediaServer.Repo
  alias MediaServer.Accounts.User
  alias MediaServer.Integrations

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Settings")
    |> assign(:users, Repo.all(User))
    |> assign(:user, User.registration_changeset(%User{}, %{}))
    |> assign(:radarr, Integrations.get_first_radarr())
    |> assign(:sonarr, Integrations.get_first_sonarr())
  end
end