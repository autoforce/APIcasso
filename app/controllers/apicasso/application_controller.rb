# frozen_string_literal: true

module Apicasso
  # Controller to extract common API features,
  # such as authentication and authorization
  class ApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods
    prepend_before_action :restrict_access, unless: -> { preflight? }
    after_action :register_api_request

    # Sets the authorization scope for the current API key
    def current_ability
      @current_ability ||= Apicasso::Ability.new(@api_key)
    end

    private

    # Identifies API key used in the request, avoiding unauthenticated access
    def restrict_access
      authenticate_or_request_with_http_token do |token, _options|
        @api_key = Apicasso::Key.find_by!(token: token)
      end
    end

    # Creates a request object in databse, registering the API key and
    # a hash of the request and the response
    def register_api_request
      Apicasso::Request.delay.create(api_key_id: @api_key.try(:id),
                                     object: { request: request_hash,
                                               response: response_hash })
    end

    # Request data built as a hash.
    # Returns UUID, URL, HTTP Headers and origin IP
    def request_hash
      {
        uuid: request.uuid,
        url: request.original_url,
        headers: request.env.select { |key, _v| key =~ /^HTTP_/ },
        ip: request.remote_ip
      }
    end

    # Resonse data built as a hash.
    # Returns HTTP Status and request body
    def response_hash
      {
        status: response.status,
        body: (response.body.present? ? JSON.parse(response.body): '')
      }
    end

    # Used to avoid errors parsing the search query,
    # which can be passed as a JSON or as a key-value param
    def parsed_query
      JSON.parse(params[:q])
    rescue JSON::ParserError, TypeError
      params[:q]
    end

    # Used to avoid errors in included associations parsing
    def parsed_include
      params[:include].split(',')
    rescue NoMethodError
      []
    end

    # Receives a `.paginate`d collection and returns the pagination
    # metadata to be merged into response
    def pagination_metadata_for(records)
      { total: records.total_entries,
        total_pages: records.total_pages,
        last_page: records.next_page.blank?,
        previous_page: previous_link_for(records),
        next_page: next_link_for(records),
        out_of_bounds: records.out_of_bounds?,
        offset: records.offset }
    end

    # Generates a contextualized URL of the next page for this request
    def next_link_for(records)
      uri = URI.parse(request.original_url)
      query = Rack::Utils.parse_query(uri.query)
      query['page'] = records.next_page
      uri.query = Rack::Utils.build_query(query)
      uri.to_s
    end

    # Generates a contextualized URL of the previous page for this request
    def previous_link_for(records)
      uri = URI.parse(request.original_url)
      query = Rack::Utils.parse_query(uri.query)
      query['page'] = records.previous_page
      uri.query = Rack::Utils.build_query(query)
      uri.to_s
    end

    # Receives a `:action, :resource, :object` hash to validate authorization
    def authorize_for(opts = {})
      authorize! opts[:action], opts[:resource] if opts[:resource].present?
      authorize! opts[:action], opts[:object] if opts[:object].present?
    end

    def set_access_control_headers
      response.headers['Access-Control-Allow-Origin'] = request.headers["Origin"]
      response.headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, PATCH, DELETE, OPTIONS'
      response.headers['Access-Control-Allow-Credentials'] = 'true'
      response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token, Auth-Token, Email, X-User-Token, X-User-Email'
      response.headers['Access-Control-Max-Age'] = '1728000'
    end

    def preflight?
      request.request_method == 'OPTIONS' &&
        !request.headers['Authorization'].present?
    end
  end
end
