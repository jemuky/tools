defmodule TransSthWeb.UserSocket do
  use Phoenix.Socket

  @impl true
  def id(_socket), do: "123"
  @impl true
  def connect(_params, t) do
    {:ok, t}
  end

  ## Channels
  channel("room:*", TransSthWeb.RoomChannel)
end
