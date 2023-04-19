defmodule MediaServer.MediaActions do
  use Ecto.Schema
  import Ecto.Changeset

  alias MediaServer.Repo

  schema "media_actions" do
    field :media_id, :integer

    belongs_to :user, MediaServer.Accounts.User
    belongs_to :media_type, MediaServer.MediaTypes
    belongs_to :action, MediaServer.Actions

    timestamps()
  end

  def changeset(media_actions, attrs) do
    media_actions
    |> cast(attrs, [:media_id, :user_id, :media_type_id, :action_id])
    |> validate_required([:media_id, :user_id, :media_type_id, :action_id])
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def all do
    Repo.all(__MODULE__)
  end

  def where(attrs) do
    Repo.get_by(__MODULE__, attrs)
  end

  def as_watched(attrs) do
    watched =
      Repo.get_by(__MODULE__,
        media_id: attrs.media_id,
        user_id: attrs.user_id,
        media_type_id: attrs.media_type_id,
        action_id: MediaServer.Actions.get_watched_id
      )

    case watched do
      nil ->
        if attrs.current_time / attrs.duration * 100 > 95 do
          create(attrs)
        else
          nil
        end
    end
  end
end
