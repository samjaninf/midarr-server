defmodule MediaServerWeb.SonarrLive.Index do
  use MediaServerWeb, :live_view

  alias MediaServer.Providers
  alias MediaServer.Providers.Sonarr

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :sonarrs, list_sonarrs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Sonarr")
    |> assign(:sonarr, Providers.get_sonarr!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Sonarr")
    |> assign(:sonarr, %Sonarr{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Sonarrs")
    |> assign(:sonarr, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    sonarr = Providers.get_sonarr!(id)
    {:ok, _} = Providers.delete_sonarr(sonarr)

    {:noreply, assign(socket, :sonarrs, list_sonarrs())}
  end

  defp list_sonarrs do
    Providers.list_sonarrs()
  end
end