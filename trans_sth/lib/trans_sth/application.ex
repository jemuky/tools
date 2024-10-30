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
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TransSthWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
