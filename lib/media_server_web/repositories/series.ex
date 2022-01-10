defmodule MediaServerWeb.Repositories.Series do

  import Ecto.Query
  alias MediaServer.Repo
  alias MediaServer.Providers.Sonarr

  def get_url(url) do
    sonarr = Sonarr |> last(:inserted_at) |> Repo.one

    "#{ sonarr.url }/#{ url }?apikey=#{ sonarr.api_key }"
  end

  def get_latest(amount) do

    case HTTPoison.get(get_url("series")) do

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decoded = Jason.decode!(body)

        Enum.sort_by(decoded, &(&1["added"]), :desc)
        |> Enum.filter(fn x -> x["sizeOnDisk"] end)
        |> Enum.take(amount)
    end
  end

  def get_all() do

    case HTTPoison.get(get_url("series")) do

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decoded = Jason.decode!(body)

        Enum.sort_by(decoded, &(&1["title"]), :asc)
    end
  end

  def get_serie(id) do

    case HTTPoison.get(get_url("series/#{ id }")) do

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode!(body)
    end
  end

  def get_episodes(series_id) do

    case HTTPoison.get("#{ get_url("episode") }&seriesId=#{ series_id }") do

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Enum.filter(Jason.decode!(body), fn x -> x["hasFile"] end)
    end
  end

  def get_episode(episode) do

    case HTTPoison.get("#{ get_url("episode/#{ episode }") }") do

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode!(body)
    end
  end

  def get_episode_path(episode) do

    case HTTPoison.get("#{ get_url("episode/#{ episode }") }") do

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decoded= Jason.decode!(body)

        decoded["episodeFile"]["path"]
    end
  end
end