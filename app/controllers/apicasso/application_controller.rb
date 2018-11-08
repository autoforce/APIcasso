# frozen_string_literal: true

module Apicasso
  # Controller to extract common API features, such as authentication and
  # authorization. Used to be inherited by non-CRUD controllers when your
  # application needs to create custom actions.
  class ApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods
    prepend_before_action :restrict_access, unless: -> { preflight? }
    before_action :set_access_control_headers
    after_action :register_api_request

    # Sets the authorization scope for the current API key, it's a getter
    # to make scoping easier
    def current_ability
      @current_ability ||= Apicasso::Ability.new(@api_key)
    end

    private

    # Identifies API key used in the request, avoiding unauthenticated access.
    # Responds with status 401 when token is not present or not found.
    # Access restriction happens on the `Authentication` HTTP header.
    # Example:
    #   curl -X GET http://example.com/objects -H 'authorization: Token token=f1e048a0b0ef4071a9a64ceecd48c64b'
    def restrict_access
      authenticate_or_request_with_http_token do |token, _options|
        @api_key = Apicasso::Key.find_by(token: token)
      end
    end

    # Creates a request object in databse, registering the API key and
    # a hash of the request and the response. It's an auditing proccess,
    # all relevant information about the requests and it's reponses get
    # recorded within the `Apicasso::Request`. This method assumes that
    # your project is using some kind of ActiveRecord extension with a
    # `.delay` method, which when not present makes your API very slow.
    def register_api_request
      Apicasso::Request.delay.create(api_key_id: @api_key.try(:id),
                                     object: { request: request_metadata,
                                               response: response_metadata })
    rescue NoMethodError
      Apicasso::Request.create(api_key_id: @api_key.try(:id),
                               object: { request: request_metadata,
                                         response: response_metadata })
    end

    # Information that gets inserted on `register_api_request` as auditing data
    # about the request. Returns a Hash with UUID, URL, HTTP Headers and IP
    def request_metadata
      {
        uuid: request.uuid,
        url: request.original_url,
        headers: request.env.select { |key, _v| key =~ /^HTTP_/ },
        ip: request.remote_ip
      }
    end

    # Information that gets inserted on `register_api_request` as auditing data
    # about the response sent back to the client. Returns HTTP Status and request body
    def response_metadata
      {
        status: response.status,
        body: (response.body.present? ? JSON.parse(response.body) : '')
      }
    end

    # A method to extract all assosciations available
    def associations_array
      resource.reflect_on_all_associations.map { |association| association.name.to_s }
    end

    # Used to avoid errors parsing the search query, which can be passed as
    # a JSON or as a key-value param. JSON is preferred because it generates
    # shorter URLs on GET parameters.
    def parsed_query
      JSON.parse(params[:q])
    rescue JSON::ParserError, TypeError
      params[:q]
    end

    # Used to avoid errors in included associations parsing and to enable a
    # insertion point for a change on splitting method.
    def parsed_associations
      params[:include].split(',').map do |param|
        if @object.respond_to?(param)
          param if associations_array.include?(param)
        end
      end.compact
    rescue NoMethodError
      []
    end

    # Used to avoid errors in included associations parsing and to enable a
    # insertion point for a change on splitting method.
    def parsed_methods
      params[:include].split(',').map do |param|
        if @object.respond_to?(param)
          param unless associations_array.include?(param)
        end
      end.compact
    rescue NoMethodError
      []
    end

    # Used to avoid errors in fieldset selection parsing and to enable a
    # insertion point for a change on splitting method.
    def parsed_select
      params[:select].split(',').map do |field|
        field if @records.column_names.include?(field)
      end
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

    # Generates a contextualized URL of the next page for the request
    def next_link_for(records)
      uri = URI.parse(request.original_url)
      query = Rack::Utils.parse_query(uri.query)
      query['page'] = records.next_page
      uri.query = Rack::Utils.build_query(query)
      uri.to_s
    end

    # Generates a contextualized URL of the previous page for the request
    def previous_link_for(records)
      uri = URI.parse(request.original_url)
      query = Rack::Utils.parse_query(uri.query)
      query['page'] = records.previous_page
      uri.query = Rack::Utils.build_query(query)
      uri.to_s
    end

    # Receives a `:action, :resource, :object` hash to validate authorization
    # Example:
    #   > authorize_for action: :read, resource: :object_class, object: :object
    def authorize_for(opts = {})
      authorize! opts[:action], opts[:resource] if opts[:resource].present?
      authorize! opts[:action], opts[:object] if opts[:object].present?
    end

    # @TODO
    # Remove this in favor of a more controllable aproach of CORS
    def set_access_control_headers
      response.headers['Access-Control-Allow-Origin'] = request.headers["Origin"]
      response.headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, PATCH, DELETE, OPTIONS'
      response.headers['Access-Control-Allow-Credentials'] = 'true'
      response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token, Auth-Token, Email, X-User-Token, X-User-Email'
      response.headers['Access-Control-Max-Age'] = '1728000'
    end

    # Checks if current request is a CORS preflight check
    def preflight?
      request.request_method == 'OPTIONS' &&
        !request.headers['Authorization'].present?
    end
  end
end
