defmodule BrigadeRestWeb.VerificationController do
  use BrigadeRestWeb, :controller
  alias Thrift.Generated.RequestHeaders
  require Thrift.Generated.EntityRole

  def verification_search(conn, params) do
    thrift_params =
      %{
        "__struct__" => "Elixir.Thrift.Generated.SearchRequest",
      }
      |> Map.merge(params)
      |> Maptu.struct!()

    # Ensure that the `max_results` parameter is set, defaults to 10
    {_, thrift_params} = Map.get_and_update(thrift_params, :max_results, fn
      nil -> {nil, 10}
      number -> {number, number}
    end)

    # Call the search method
    result = Thrift.Generated.VerificationService.Binary.Framed.Client.search!(
      :verification_service,
      get_request_header(),
      thrift_params
    )

    # Encode the result as JSON and write it to the client connection
    Plug.Conn.send_resp(conn, 200, Poison.encode!(result))
  end

  defp get_request_header do
    %RequestHeaders{
      request_id: UUID.uuid1(),
      entity: %Thrift.Generated.Entity{
        role: Thrift.Generated.EntityRole.guest(),  # NOTE: this may need to be set as admin
      }
    }
  end
end
