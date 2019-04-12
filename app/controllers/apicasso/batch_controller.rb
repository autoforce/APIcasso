# frozen_string_literal: true

module Apicasso
  # Controller to consume read-only data to be used on client's frontend
  class BatchController < Apicasso::ApplicationController
    include SqlSecurity
    include CrudUtils

    # POST /batch_create
    # This action creates records based on request payload. It reads the JSON
    # taking it's keys as model scope and array values as records to create.
    def batch_create
      params[:batch]&.to_unsafe_h&.each do |batch_resource, objects|
        batch_resource = batch_resource.to_s
        batch_module = batch_resource.underscore.singularize.to_sym
        resource = batch_resource.classify.constantize
        authorize_for(action: :create,
                      resource: batch_module)
        objects.each do |batch_object|
          authorize_for(action: :create,
                        resource: batch_module,
                        object: resource.new(batch_object))
        end
        resource.create!(objects)
      end
      head :created if params[:batch].present?
    end

    # GET /ql
    # This action takes a JSON as argument with models as keys and ransack
    # conditions as values, returning a custom indexed payload.
    # WARNING: This action is not paginated, so thread carefully when using it.
    def ql
      returns = params[:batch].to_unsafe_h.map do |batch_resource, query|
        batch_resource = batch_resource.to_s
        batch_module = batch_resource.underscore
        resource = batch_resource.classify.constantize
        authorize_for(action: :index,
                      resource: batch_module.singularize.to_sym)
        records = resource.ransack(parsed_query(query)).result.as_json
        [batch_module, records]
      end.to_h
      render json: returns
    end

    # PATCH/PUT /batch_update
    # This action updates records based on request payload. It reads the JSON
    # taking it's keys as model scope and array values as records to update
    # through it's ids.
    def batch_update
      params[:batch]&.to_unsafe_h&.each do |batch_resource, objects|
        objects = Array.wrap(objects).select { |object| object['id'].present? }
        batch_resource = batch_resource.to_s
        batch_module = batch_resource.underscore.singularize.to_sym
        resource = batch_resource.classify.constantize
        authorize_for(action: :update,
                      resource: batch_module)
        objects.each do |batch_object|
          authorize_for(action: :update,
                        resource: batch_module,
                        object: resource.new(batch_object))
        end
        resource.update(objects.map { |obj| obj['id']}, objects)
      end
      head :accepted if params[:batch].present?
    end

    def resource
      params[:batch].to_unsafe_h.keys.map do |klass|
        klass.singularize.classify.constantize
      end
    end
  end
end
