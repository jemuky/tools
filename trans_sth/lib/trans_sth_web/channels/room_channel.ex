defmodule TransSthWeb.RoomChannel do
  require Logger
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, socket) do
    # {:error, %{reason: "unauthorized"}}
    # broadcast!(socket, "phx_join", "ok")
    # send(socket, "ok")
    {:ok, socket}
  end

  @doc """
  断开连接事件
  """

  def terminate(_reason, _arg1) do
    Logger.info("terminate")
    :normal
  end

  @doc """
  服务器将消息主动发送给客户端
  """
  def handle_out("new_msg", _payload, socket) do
    Logger.info("handle_out")
    {:noreply, socket}
  end

  @doc """
  事件传入
  """
  def handle_in("new_msg", payload, socket) do
    broadcast!(socket, "new_msg", "ok")
    Logger.info("收到消息: " <> payload["text"])
    {:noreply, socket}
  end
end
