defmodule BrigadeRestWeb.Router do
  use BrigadeRestWeb, :router

  pipeline :browser do
    plug :accepts, ["application/json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BrigadeRestWeb.SimpleApiKeyAuthPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BrigadeRestWeb do
    pipe_through :browser # Use the default browser stack
    get "/***REMOVED***/search", VerificationController, :verification_search
    get "/:service_name/:request_name", DynamicThriftController, :request
  end


  # Other scopes may use custom stacks.
  # scope "/api", BrigadeRestWeb do
  #   pipe_through :api
  # end
end
