defmodule TransSthWeb.ShowController do
  use TransSthWeb, :controller
  use Gettext, backend: TransSthWeb.Gettext

  plug(TransSthWeb.Plugs.Locale, "en" when action in [:show])

  def show(conn, %{"messenger" => messenger}) do
    render(conn, :show, messenger: messenger)
  end
end
