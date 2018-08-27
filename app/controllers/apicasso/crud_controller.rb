# frozen_string_literal: true

module Apicasso
  # Controller to consume read-only data to be used on client's frontend
  class CrudController < Apicasso::ApplicationController
    before_action :set_root_resource
    before_action :set_object, except: %i[index schema create]
    before_action :set_nested_resource, only: %i[nested_index]
    before_action :set_records, only: %i[index nested_index]

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
      render json: index_json
    end

    # GET /:resource/1
    def show
      render json: @object.to_json(include: parsed_include)
    end

    # PATCH/PUT /:resource/1
    def update
      authorize_for(action: :update,
                    resource: resource.name.underscore.to_sym,
                    object: @object)
      if @object.update(object_params)
        render json: @object
      else
        render json: @object.errors, status: :unprocessable_entity
      end
    end

    # DELETE /:resource/1
    def destroy
      authorize_for(action: :destroy,
                    resource: resource.name.underscore.to_sym,
                    object: @object)
      if @object.destroy
        head :no_content
      else
        render json: @object.errors, status: :unprocessable_entity
      end
    end

    # GET /:resource/1/:nested_resource
    alias nested_index index

    # POST /:resource
    def create
      @object = resource.new(resource_params)
      authorize_for(action: :create,
                    resource: resource.name.underscore.to_sym,
                    object: @object)
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
      if preflight?
        set_access_control_headers
        head :no_content
      else
        render json: resource_schema.to_json
      end
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
      select_fields if params[:select].present?
    end

    # Selects a fieldset that should be returned, instead of all fields
    # from records.
    def select_fields
      @records = @records.select(*params[:select].split(','))
    end

    # Reordering of records which happens when receiving `params[:sort]`
    def reorder_records
      @records = @records.unscope(:order).order(ordering_params(params))
    end

    # Raw paginated records object
    def paginated_records
      accessible_records
        .paginate(page: params[:page], per_page: params[:per_page])
    end

    # Records that can be accessed from current Apicasso::Key scope
    # permissions
    def accessible_records
      @records.accessible_by(current_ability).unscope(:order)
    end

    # The response for index action, which can be a pagination of a record collection
    # or a grouped count of attributes
    def index_json
      if params[:group].present?
        accessible_records.group(params[:group].split(',')).count
      else
        collection_response
      end
    end

    # Parsing of `paginated_records` with pagination variables metadata
    def built_paginated
      { entries: entries_json }.merge(pagination_metadata_for(paginated_records))
    end

    # All records matching current query and it's total
    def built_unpaginated
      { entries: accessible_records, total: accessible_records.size }
    end

    # Parsed JSON to be used as response payload
    def entries_json
      JSON.parse(paginated_records.to_json(include: parsed_include))
    end

    # Returns the collection checking if it needs pagination
    def collection_response
      if params[:per_page].to_i == -1
        built_unpaginated
      else
        built_paginated
      end
    end

    # Only allow a trusted parameter "white list" through,
    # based on resource's schema.
    def object_params
      params.fetch(resource.name.underscore.to_sym, resource_schema.keys)
    end
  end
end
