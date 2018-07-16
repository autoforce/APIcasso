# frozen_string_literal: true

module Apicasso
  # Controller to consume read-only data to be used on client's frontend
  class CrudController < ApplicationController
    before_action :set_root_resource
    before_action :set_object, except: %i[index schema create]
    before_action :set_nested_resource, only: %i[nested_index]
    before_action :set_records, only: %i[index nested_index]
    before_action :set_schema, only: %i[schema]

    include Orderable

    # GET /:resource
    # Returns a paginated, ordered and filtered query based response.
    # Consider this
    # To get all `Channel` sorted by ascending `name` and descending
    # `updated_at`, filtered by the ones that have a `domain` that matches
    # exactly `"domain.com"`, paginating records 42 per page and retrieving
    # the page 42 of that collection. Usage:
    # GET /sites?sort=+name,-updated_at&q[domain_eq]=domain.com&page=42&per_page=42
    def index
      render json: response_json
    end

    # GET /:resource/1
    def show
      render json: @object.to_json(include: parsed_include)
    end

    # PATCH/PUT /:resource/1
    def update
      if @object.update(object_params)
        render json: @object
      else
        render json: @object.errors, status: :unprocessable_entity
      end
    end

    # GET /:resource/1/:nested_resource
    alias nested_index index

    # POST /:resource
    def create
      @object = resource.new(resource_params)
      if @object.save
        render json: @object, status: :created, location: @object
      else
        render json: @object.errors, status: :unprocessable_entity
      end
    end

    # OPTIONS /:resource
    # OPTIONS /:resource/1/:nested_resource
    # Will return a JSON with the schema of the current resource, using
    # attribute names as keys and attirbute types as values.
    def schema
      render json: resource_schema.to_json
    end

    private

    # Common setup to stablish which model is the resource of this request
    def set_root_resource
      @root_resource = params[:resource].classify.constantize
    end

    # Common setup to stablish which object this request is querying
    def set_object
      id = params[:id]
      @object = resource.friendly.find(id)
    rescue NoMethodError
      @object = resource.find(id)
    ensure
      authorize! :read, @object
    end

    # Setup to stablish the nested model to be queried
    def set_nested_resource
      @nested_resource = @object.send(params[:nested].underscore.pluralize)
    end

    # Reutrns root_resource if nested_resource is not set scoped by permissions
    def resource
      (@nested_resource || @root_resource)
    end

    # Used to setup the resource's schema, mapping attributes and it's types
    def resource_schema
      schemated = {}
      resource.columns_hash.each { |key, value| schemated[key] = value.type }
      schemated
    end

    # Used to setup the records from the selected resource that are
    # going to be rendered, if authorized
    def set_records
      authorize! :read, resource.name.underscore.to_sym
      @records = resource.ransack(parsed_query).result
      reorder_records if params[:sort].present?
    end

    # Reordering of records which happens when receiving `params[:sort]`
    def reorder_records
      @records = @records.unscope(:order).order(ordering_params(params))
    end

    # Raw paginated records object
    def paginated_records
      @records.accessible_by(current_ability)
              .paginate(page: params[:page], per_page: params[:per_page])
    end

    # Parsing of `paginated_records` with pagination variables metadata
    def response_json
      { entries: entries_json }.merge(pagination_metadata_for(paginated_records))
    end

    # Parsed JSON to be used as response payload
    def entries_json
      JSON.parse(paginated_records.to_json(include: parsed_include))
    end

    # Only allow a trusted parameter "white list" through,
    # based on resource's schema.
    def object_params
      params.fetch(resource.name.underscore.to_sym, resource_schema.keys)
    end
  end
end
