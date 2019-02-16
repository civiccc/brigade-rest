# This file is used to provide simple API authorization based on an API key authorization
# This module implements a `Plug.Conn` interface, and can be used like all `Plug.Conn` modules
# to chain together actions for a connection (request + response).
# See: https://hexdocs.pm/plug/Plug.Conn.html

# This plug will look to see if the API key provided in the `x-brigade-rest-api-key` header
# is in the `allowed_api_keys` list defined in the application config.

defmodule BrigadeRestWeb.SimpleApiKeyAuthPlug do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    key =
      conn
      |> get_req_header("x-brigade-rest-api-key") # returns a list, e.g. ["foo-key-bar"]
      |> List.first()

    allowed_keys =
      Application.get_env(:brigade_rest, BrigadeRestWeb.Endpoint)
      |> Keyword.get(:allowed_api_keys, [])

    # If they are not authorized a simple "Not authorized" string is sent and a 401, and the
    # connection is halted - otherwise the connection passes through, doing nothing here.
    if Enum.member?(allowed_keys, key) do
      conn
    else
      Plug.Conn.send_resp(conn, 401, "Not authorized")
      halt(conn)
    end
  end

end
