defmodule BitConverter do
  import Bitwise

  def to_bits(binary) do
    binary
    |> :binary.bin_to_list()
    |> Enum.flat_map(&byte_to_bits/1)
  end

  defp byte_to_bits(byte) do
    for i <- 7..0 do
      byte >>> i &&& 1
    end
  end
end

defmodule TransSth.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TransSthWeb.Telemetry,
      # TransSth.Repo,
      {DNSCluster, query: Application.get_env(:trans_sth, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TransSth.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: TransSth.Finch},
      # Start a worker by calling: TransSth.Worker.start_link(arg)
      # {TransSth.Worker, arg},
      # Start to serve requests, typically the last entry
      TransSthWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TransSth.Supervisor]

    ret = Supervisor.start_link(children, opts)
    pid = spawn(&after_start/0)
    send(pid, :start)
    ret
  end

  defp after_start() do
    :timer.sleep(2000)

    receive do
      :start ->
        address = get_local_ipv4_address()
        show_address(address, 1)
        choose_num = choose(1..length(address))

        data = "http://" <> Enum.at(address, choose_num - 1) <> ":4000"
        qrcode = QRCode.to_png(data)
        File.write("log/qrcode.png", qrcode)
        # IO.puts("qrcode: " <> inspect(qrcode))
        # print_qr_code(BitConverter.to_bits(qrcode))
    end
  end

  defp print_qr_code(qr_code) do
    qr_code
    |> Enum.each(fn row ->
      row
      |> Enum.map(fn
        # 黑色方块
        1 -> "██"
        # 空白
        0 -> "  "
      end)
      # 打印每一行
      |> IO.puts()
    end)
  end

  defp choose(range) do
    option = IO.gets("选择一个ip的序号: ")
    option = option |> String.graphemes() |> hd
    IO.puts("选择了: <" <> option <> ">")

    try do
      opt_num = String.to_integer(option)

      unless Enum.member?(range, opt_num) do
        IO.puts("错误的选择，重新选择")
        choose(range)
      end

      opt_num
    rescue
      e ->
        IO.puts("发生错误，重新选择，" <> inspect(e))
        choose(range)
    end
  end

  defp show_address(address, _index) when is_list(address) and length(address) == 0 do
    :ok
  end

  defp show_address(address, index) do
    IO.puts(to_string(index) <> ". " <> hd(address))
    show_address(tl(address), index + 1)
  end

  defp get_local_ipv4_address do
    # 获取所有网络接口的信息
    {:ok, interfaces} = :inet.getif()

    # IO.puts(inspect(interfaces))

    interfaces
    |> Enum.flat_map(fn addr ->
      # 过滤出IPv4地址
      case addr do
        {ipv4, _, _mask} -> [ipv4]
        _ -> []
      end
    end)
    |> Enum.map(fn {a, b, c, d} -> "#{a}.#{b}.#{c}.#{d}" end)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TransSthWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
