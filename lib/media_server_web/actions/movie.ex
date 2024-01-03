defmodule MediaServerWeb.Actions.Movie do
  require Logger

  def handle_info({:added, %{"movie" => %{"id" => id, "title" => title}}}) do
    MediaServer.MoviesIndex.reset()

    case Application.get_env(:media_server, :web_push_elixir) do
      nil ->
        Logger.info("Config required to send notifications")
      _ ->
        followers = MediaServer.MediaActions.movie(id) |> MediaServer.MediaActions.followers()

        Enum.each(followers, fn media_action ->
          Enum.each(media_action.user.push_subscriptions, fn push_subscription ->
            WebPushElixir.send_notification(
              push_subscription.push_subscription,
              "#{title} available"
            )
          end)
        end)
    end
  end

  def handle_info({:deleted}) do
    MediaServer.MoviesIndex.reset()
  end

  def handle_info({:deleted_file}) do
    MediaServer.MoviesIndex.reset()
  end
end
