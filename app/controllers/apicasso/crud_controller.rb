# frozen_string_literal: true

module Apicasso
  # Controller to consume read-only data to be used on client's frontend
  class CrudController < Apicasso::ApplicationController
    before_action :set_root_resource
    before_action :set_object, except: %i[index create schema]
    before_action :set_nested_resource, only: %i[nested_index]
    before_action :set_records, only: %i[index nested_index]
    include SqlSecurity
    include CrudUtils
    include Orderable
    # GET /:resource
    # Returns a paginated, ordered and filtered query based response.
    # Consider this
    # To get all `Channel` sorted by ascending `name` , filtered by
    # the ones that have a `domain` that matches exactly `"domain.com"`,
    # paginating records 42 per page and retrieving the page 42.
    # Example:
    #   GET /sites?sort=+name,-updated_at&q[domain_eq]=domain.com&page=42&per_page=42
    def index
      render json: index_json
    end

    # GET /:resource/1
    # Common behavior for showing a record, with an addition of
    # relation/methods including on response
    def show
      render json: show_json
    end

    # PATCH/PUT /:resource/1
    # Common behavior for an update API endpoint
    def update
      authorize_for(action: :update,
                    resource: resource.name.underscore.to_sym,
                    object: @object)
      if @object.update(object_params)
        render json: @object.to_json
      else
        render json: @object.errors, status: :unprocessable_entity
      end
    end

    # DELETE /:resource/1
    # Common behavior for an destroy API endpoint
    def destroy
      authorize_for(action: :destroy,
                    resource: resource.name.underscore.to_sym,
                    object: @object)
      if @object.destroy
        head :no_content, status: :ok
      else
        render json: @object.errors, status: :unprocessable_entity
      end
    end

    # GET /:resource/1/:nested_resource
    alias nested_index index

    # POST /:resource
    def create
      @object = resource.new(object_params)
      authorize_for(action: :create,
                    resource: resource.name.underscore.to_sym,
                    object: @object)
      if @object.save
        render json: @object.to_json, status: :created
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

    # Common setup to stablish which object this request is querying
    def set_object
      id = params[:id]
      @object = resource.friendly.find(id)
    rescue NoMethodError
      @object = resource.find(id)
    ensure
      authorize! action_to_cancancan, @object
    end

    # Used to setup the records from the selected resource that are
    # going to be rendered, if authorized
    def set_records
      authorize! :read, resource.name.underscore.to_sym
      @records = resource.ransack(parsed_query).result
      @object = resource.new
      key_scope_records
      reorder_records if params[:sort].present?
      select_fields if params[:select].present?
      include_relations if params[:include].present?
    end

    # Selects a fieldset that should be returned, instead of all fields
    # from records.
    def select_fields
      @records = @records.select(*parsed_select)
    end

    # Reordering of records which happens when receiving `params[:sort]`
    def reorder_records
      @records = @records.unscope(:order).order(ordering_params(params))
    end

    # Raw paginated records object
    def paginated_records
      @records
        .paginate(page: params[:page], per_page: params[:per_page])
    end

    # Records that can be accessed from current Apicasso::Key scope
    # permissions
    def key_scope_records
      @records = @records.accessible_by(current_ability).unscope(:order)
    end

    # The response for index action, which can be a pagination of a
    # record collection or a grouped count of attributes
    def index_json
      if params[:group].present?
        @records.group(params[:group][:by].split(','))
                .send(:calculate,
                      params[:group][:calculate],
                      params[:group][:field])
      else
        collection_response
      end
    end

    # The response for show action, which can be a fieldset
    # or a full response of attributes
    def show_json
      json_hash = include_options
      json_hash[:only] = parsed_select if params[:select].present?
      @object.as_json(json_hash)
    end

    # Parsing of `paginated_records` with pagination variables metadata
    def built_paginated
      { entries: paginated_records.as_json(include_options) }
        .merge(pagination_metadata_for(paginated_records))
    end

    # All records matching current query and it's total
    def built_unpaginated
      { entries: @records.as_json(include_options),
        total: @records.size }
    end

    # Parsed JSON to be used as response payload, with included relations
    def include_relations
      @records = @records.includes(parsed_associations)
    end

    # Returns the collection checking if it needs pagination
    def collection_response
      if params[:per_page].to_i < 0
        built_unpaginated
      else
        built_paginated
      end
    end

    # Common setup to stablish which model is the resource of this request
    def set_root_resource
      @root_resource = params[:resource].classify.constantize
    end

    # Setup to stablish the nested model to be queried
    def set_nested_resource
      @nested_resource = @object.send(params[:nested].underscore.pluralize)
    end
  end
end
