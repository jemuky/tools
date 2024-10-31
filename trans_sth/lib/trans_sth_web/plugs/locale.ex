defmodule TransSthWeb.Plugs.Locale do
  require Logger
  import Plug.Conn

  @locales ["zh", "en", "fr", "de"]

  def init(default), do: default

  def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _default) when loc in @locales do
    Logger.info("123" <> loc)
    assign(conn, :locale, loc)
  end

  def call(conn, default) do
    Logger.info("456")
    assign(conn, :locale, default)
  end
end
