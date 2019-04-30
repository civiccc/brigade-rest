defmodule BrigadeRest.Application do
  use Application
  import Supervisor.Spec

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised

    # NOTE: children are managed by a supervisor via the `strategy` defined below, they
    # are referenced by `name` in their configurations, so they can be used globally by
    # the endpoints via namespace. For instance the CivicDataService.Binary.Framed.Client can
    # use the `:civic_data_service` namespace instead of providing the `PID`, it will be
    # globally accessible.

    children = [
      # Start the endpoint when the application starts
      supervisor(BrigadeRestWeb.Endpoint, []),
      civic_data_service(),
      action_service(),
      campaign_service(),
      verification_service(),

      # Add your own service client configuration here, see `civic_data_service/0` for details
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BrigadeRest.Supervisor]
    Supervisor.start_link(children, opts)

  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BrigadeRestWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp civic_data_service() do
    config = Application.get_env(:brigade_rest, :civic_data_service, [])
    host = Keyword.fetch!(config, :host)
    port = Keyword.fetch!(config, :port)

    assert_host_port_valid(:civic_data_service, host, port)

    opts =
      config
      |> Keyword.get(:options, [])
      |> Keyword.put(:name, :civic_data_service)

    worker(
      Thrift.Generated.CivicDataService.Binary.Framed.Client,
      [host, port, opts]
    )
  end

  defp action_service() do
    config = Application.get_env(:brigade_rest, :action_service, [])
    host = Keyword.fetch!(config, :host)
    port = Keyword.fetch!(config, :port)

    assert_host_port_valid(:action_service, host, port)

    opts =
      config
      |> Keyword.get(:options, [])
      |> Keyword.put(:name, :action_service)

    worker(
      Thrift.Generated.ActionService.Binary.Framed.Client,
      [host, port, opts]
    )
  end

  defp campaign_service() do
    config = Application.get_env(:brigade_rest, :campaign_service, [])
    host = Keyword.fetch!(config, :host)
    port = Keyword.fetch!(config, :port)

    assert_host_port_valid(:campaign_service, host, port)

    opts =
      config
      |> Keyword.get(:options, [])
      |> Keyword.put(:name, :campaign_service)

    worker(
      Thrift.Generated.CampaignService.Binary.Framed.Client,
      [host, port, opts]
    )
  end

  defp verification_service() do
    config = Application.get_env(:brigade_rest, :verification_service, [])
    host = Keyword.fetch!(config, :host)
    port = Keyword.fetch!(config, :port)

    assert_host_port_valid(:verification_service, host, port)

    opts =
      config
      |> Keyword.get(:options, [])
      |> Keyword.put(:name, :verification_service)

    worker(
      Thrift.Generated.VerificationService.Binary.Framed.Client,
      [host, port, opts]
    )
  end

  # Ensure that clients have a valid setup before they attempt to connect
  defp assert_host_port_valid(service, host, port) do
    if not(is_binary(host)) do
      raise "Invalid host provided for #{service} client #{host}"
    end
    if not(is_integer(port)) do
      raise "Invalid port provided for #{service} client #{port}"
    end
  end
end
