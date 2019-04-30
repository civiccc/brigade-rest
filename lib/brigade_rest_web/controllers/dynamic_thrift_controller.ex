defmodule BrigadeRestWeb.DynamicThriftController do
  use BrigadeRestWeb, :controller
  alias Thrift.Generated.RequestHeaders
  alias Thrift.Generated.BoundaryLimitPaginationParams
  require Thrift.Generated.EntityRole

  def index(conn, _params) do
    Plug.Conn.send_resp(conn, 200, "Brigade Rest API")
  end

  def request(conn, params) do
    # Get the pagination parameter information
    limit = String.to_integer(Map.get(params, "limit", "10"))
    direction = String.to_integer(Map.get(params, "direction", "0"))
    boundary_uid = Map.get(params, "cursor", nil)
    service_name = Map.fetch!(params, "service_name")

    # Generate the Thrift Request struct from the request name and params object
    request_struct =
      %{
        "__struct__" => "Elixir.Thrift.Generated.#{get_request_name_camel_case(params)}Request",
      }
      |> Map.merge(Map.get(params, "parameters", %{
        "pagination_params" => %BoundaryLimitPaginationParams{
          limit: limit,
          direction: direction,
          boundary_uid: boundary_uid,
        },
        "filter_params" => get_filter_params(
          "Elixir.Thrift.Generated.#{get_request_name_camel_case(params)}Request",
          params
        ),
      }))
      |> Maptu.struct!()  # Converts the Map %{} to a named struct %SomeName{}

    # Get the client module via the service_name parameter
    client_module = String.to_existing_atom(
      "Elixir.Thrift.Generated.#{Macro.camelize(service_name)}.Binary.Framed.Client"
    )

    args = [
      String.to_existing_atom(service_name),  # the global namespace for a given client, e.g. :verification_service
      get_request_header(),  # request header struct
      request_struct  # request parameter struct
    ]

    # Do the call to the client and format the result
    result =
      client_module
      |> apply(String.to_existing_atom("#{get_request_name(params)}!"), args)
      |> format_result(params)

    # Encode the result as JSON and write it to the client http connection
    Plug.Conn.send_resp(conn, 200, Poison.encode!(result))
  end

  defp get_filter_params(_, params) do
    # generate regular params
  end

  defp format_result(result, params) do
    result =
      result
      |> Poison.encode!()
      |> Poison.decode!()

    list_length =
      result
      |> get_in([get_result_field(params)])
      |> length()

    # Update the page info to contain a cursor field that is the last element of the returned list
    result
    |> update_in(
      ["page_info"],
      fn info ->
        Map.merge(
          info,
          %{"cursor" => get_in(
            result,
            [get_result_field(params), Access.at(list_length - 1), "uid"]
          )}
        )
      end
    )
  end

  defp get_request_name(params), do: Map.fetch!(params, "request_name")
  defp get_request_name_camel_case(params), do: get_request_name(params) |> Macro.camelize()
  defp get_result_field(params), do: get_request_name(params) |> String.split("get_") |> Enum.at(1)
  defp get_request_header do
    %RequestHeaders{
      request_id: UUID.uuid1(),
      entity: %Thrift.Generated.Entity{
        role: Thrift.Generated.EntityRole.guest(),
      }
    }
  end
end
