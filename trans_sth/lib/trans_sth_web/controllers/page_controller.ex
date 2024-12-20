defmodule TransSthWeb.PageController do
  use TransSthWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    conn
    |> put_flash(:error, "Let's pretend we have an error.")
    |> render(:home, layout: false)

    # conn
    # |> put_resp_content_type("text/plain")
    # |> send_resp(201, "213")
  end
end
