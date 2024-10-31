defmodule TransSthWeb.ApiController do
  require Logger
  use TransSthWeb, :controller

  defp trans_file_p(%{"file" => file, "path" => path}) do
    case file do
      %Plug.Upload{path: fpath} ->
        path = if String.length(path) == 0, do: "./tmp/file/", else: path

        case File.mkdir_p(path) do
          {:error, err} ->
            err

          _ ->
            File.cp(fpath, path <> file.filename)
            :ok
        end

      err ->
        Logger.error("err: " <> to_string(err))
        err
    end
  end

  def trans_file(conn, %{"file" => file, "path" => path}) do
    Logger.debug("enter trans_file")

    data = trans_file_p(%{"file" => file, "path" => path})

    json(conn, %{
      code: if(data != :ok, do: -1, else: 0),
      msg: if(data != :ok, do: data, else: nil)
    })
  end

  def trans_file(conn, %{"file" => file}) do
    trans_file(conn, %{"file" => file, "path" => "./tmp/file/"})
  end

  def trans_file(conn, %{"files" => files}) when is_list(files) and length(files) == 0 do
    json(conn, %{code: 0})
  end

  def trans_file(conn, %{"files" => files}) when is_list(files) do
    trans_file_p(%{"file" => hd(files), "path" => "./tmp/file/"})
    trans_file(conn, %{"files" => tl(files)})
  end

  def trans_file(conn, param) do
    Logger.error("trans_file err param, param=" <> inspect(param))
    json(conn, %{code: -1})
  end

  def trans_text(conn, %{"text" => text}) do
    Logger.info("trans_text text=" <> to_string(text))
    json(conn, %{code: 0})
  end

  def trans_text(conn, param) do
    Logger.error("trans_text err param, param=" <> inspect(param))
    json(conn, %{code: -1})
  end
end
