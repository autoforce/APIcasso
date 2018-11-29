# frozen_string_literal: true

# Module to extract utilities used on CRUD controllers.
# It makes it easier to parse parameters, proccess requests
# and build rich responses.
module CrudUtils
  extend ActiveSupport::Concern

  # Reutrns root_resource if nested_resource is not set scoped by permissions
  def resource
    (@nested_resource || @root_resource)
  end

  # A method to extract all assosciations available
  def associations_array
    resource.reflect_on_all_associations.map { |association| association.name.to_s }
  end

  # An parser to the action name so that nested_index has the same
  # authorization behavior as index
  def action_to_cancancan
    action_name == 'nested_index' ? :index : action_name.to_sym
  end

  # Resource params mapping, with a twist:
  # Including relations as they are needed
  def resource_params
    built = resource_schema.keys
    built += has_one_params if has_one_params.present?
    built += has_many_params if has_many_params.present?
    built
  end

  # A wrapper to has_one relations parameter building
  def has_one_params
    resource.reflect_on_all_associations(:has_one).map do |one|
      if one.class_name.starts_with?('ActiveStorage')
        next if one.class_name.ends_with?('Blob')

        one.name.to_s.gsub(/(_attachment)$/, '').to_sym
      else
        one.name
      end
    end.compact
  end

  # A wrapper to has_many parameter building
  def has_many_params
    resource.reflect_on_all_associations(:has_many).map do |many|
      if many.class_name.starts_with?('ActiveStorage')
        next if many.class_name.ends_with?('Blob')

        { many.name.to_s.gsub(/(_attachments)$/, '').to_sym => [] }
      else
        { many.name.to_sym => [] }
      end
    end.compact
  end

  # Parse to include options
  def include_options
    { include: parsed_associations || [],
      methods: parsed_methods || [] }
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
      field if resource.column_names.include?(field)
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
    page_link(records, page: 'next')
  end

  # Generates a contextualized URL of the previous page for the request
  def previous_link_for(records)
    page_link(records, page: 'previous')
  end

  # Common pagination link generation helper
  def page_link(records, opts = {})
    uri = URI.parse(request.original_url)
    query = Rack::Utils.parse_query(uri.query)
    query['page'] = records.send("#{opts[:page]}_page")
    uri.query = Rack::Utils.build_query(query)
    uri.to_s
  end
end
