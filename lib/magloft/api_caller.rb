module MagLoft
  class ApiCaller < Dialers::Caller
    MAX_RETRIES = 0
    TIMEOUT_IN_SECONDS = 600
    MAGLOFT_API_URL = "https://www.magloft.com"
    MAGLOFT_CDN_URL = "https://storage.googleapis.com/cdn.magloft.com/"

    setup_api(url: MAGLOFT_API_URL) do |faraday|
      faraday.request :json
      faraday.request :request_headers, accept: "application/json"
      faraday.response :json
      faraday.adapter :net_http
      faraday.options.timeout = TIMEOUT_IN_SECONDS
      faraday.options.open_timeout = TIMEOUT_IN_SECONDS
      faraday.ssl.verify = false
    end

    def http_call(request_options, current_retries = 0)
      request_options.headers["X-Magloft-Accesstoken"] = Api.client.token
      super
    end

    def transform(response)
      self.class.short_circuits.search_for_stops(response)
      Transformable.new(response)
    end

    short_circuits.add(
      if: -> (response) { Dialers::Status.new(response.status).server_error? },
      do: -> (response) { fail Dialers::ServerError, response }
    )

    short_circuits.add(
      if: -> (response) { Dialers::Status.new(response.status).is?(404) },
      do: -> (response) { fail Dialers::NotFoundError, response }
    )

    short_circuits.add(
      if: -> (response) { Dialers::Status.new(response.status).is?(409) },
      do: -> (response) { fail ConflictError, response }
    )

    short_circuits.add(
      if: -> (response) { Dialers::Status.new(response.status).is?(400) },
      do: -> (response) { fail ValidationError, response }
    )

    short_circuits.add(
      if: -> (response) { Dialers::Status.new(response.status).is?(422) },
      do: -> (response) { fail ValidationError, response }
    )
    
    short_circuits.add(
      if: -> (response) { Dialers::Status.new(response.status).is?(401) },
      do: -> (response) { fail UnauthorizedError, response }
    )

    class ConflictError < Dialers::ErrorWithResponse
    end

    class ValidationError < Dialers::ErrorWithResponse
    end
    
    class UnauthorizedError < Dialers::ErrorWithResponse
    end
  end
end
