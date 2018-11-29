# frozen_string_literal: true

module Apicasso
  # Controller to extract common API features, such as authentication and
  # authorization. Used to be inherited by non-CRUD controllers when your
  # application needs to create custom actions.
  class ApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods
    prepend_before_action :restrict_access
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
        body: parsed_response
      }
    end

    # Parsed response to save as metadata for the requests
    def parsed_response
      (response.body.present? ? JSON.parse(response.body) : '')
    end

    # Receives a `:action, :resource, :object` hash to validate authorization
    # Example:
    #   > authorize_for action: :read, resource: :object_class, object: :object
    def authorize_for(opts = {})
      authorize! opts[:action], opts[:resource] if opts[:resource].present?
      authorize! opts[:action], opts[:object] if opts[:object].present?
    end
  end
end
