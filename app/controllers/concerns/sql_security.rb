# frozen_string_literal: true

# This concern is used to check SQL injection
module SqlSecurity
  extend ActiveSupport::Concern

  included do
    # All requests should use the klasses within the ones allowed
    prepend_before_action :klasses_allowed
    # Requests should be checked against a set of security rules
    append_before_action :bad_request?
  end

  # To be sure that all application classes are loaded
  Rails.application.eager_load!
  # A list of all models within the application
  DESCENDANTS_UNDERSCORED = ActiveRecord::Base.descendants.map do |descendant|
    descendant.to_s.underscore
  end.freeze

  # Available calculations on params[:group] requests
  GROUP_CALCULATE = %w[
    average
    calculate
    count
    ids
    maximum
    minimum
    pluck
    sum
  ].freeze

  # Check if request is a SQL injection
  def sql_injection(klass, hash = nil)
    apicasso_parameters(hash).each do |name, value|
      next unless Array.wrap(klass).any? do |klass|
        !safe_parameter?(klass, name, value)
      end
      return true
    end
    false
  end

  private

  # Given a klass, is a the value safe to use in a query?
  def safe_parameter?(klass, name, value)
    if name.to_sym == :group
      group_sql_safe?(klass, value)
    elsif name.to_sym == :batch
      value.each do |name, val|
        parameters_sql_safe?(klass.name.singularize.constantize, name)
        Array.wrap(value).each do |inner_val|
          sql_injection(klass, inner_val)
        end
      end
    else
      parameters_sql_safe?(klass, value)
    end
  end

  # Check for SQL injection before requests to avoid unsafe
  # contantizes and evals along the execution chain
  def bad_request?
    if if params[:sort] != 'rand'
      raise ActionController::BadRequest.new("Bad hacker, stop bullying or I'll tell your mom!") if sql_injection(resource)
    end
  end

  # Check for requests using classes outside the application scope,
  # like Kernel or others that could lead to a vulnerability
  def klasses_allowed
    raise ActionController::BadRequest.new("Bad hacker, stop bullying or I'll tell your mom!") unless safe_resource?
  end

  # Is the resource safe to constantize?
  def safe_resource?
    controller_name == representative_resource ||
      DESCENDANTS_UNDERSCORED.include?(param_attribute.to_s.underscore) ||
      safe_batch_resources?
  end

  # Are the batch resources safe?
  def safe_batch_resources?
    params[:batch]&.keys&.all? do |klass|
      DESCENDANTS_UNDERSCORED.include?(klass.singularize)
    end
  end

  # Parametrize the resource for the CRUD request
  def param_attribute
    representative_resource.singularize
  end

  # Define the resource that is the object for the current request
  def representative_resource
    (params[:nested] || params[:resource] || controller_name)
  end

  # Check if group params is safe from SQL injection
  def group_sql_safe?(klass, value)
    value.each do |group_key, group_value|
      if group_key.to_sym == :calculate
        return false unless GROUP_CALCULATE.include?(group_value)
      else
        return false unless safe_for_sql?(klass, group_value)
      end
    end
    true
  end

  # Check if regular params is safe from SQL injection
  def parameters_sql_safe?(klass, value)
    value.split(',').each do |param|
      return false unless safe_for_sql?(klass, param.gsub(/\A[+-]/, ''))
    end
    true
  end

  # Check if value for current class is valid for APIcasso consumption
  def safe_for_sql?(klass, value)
    klass.column_names.include?(value) ||
      DESCENDANTS_UNDERSCORED.include?(value.singularize) ||
      klass.new.respond_to?(value) ||
      klass.reflect_on_all_associations.map(&:name).include?(value)
  end

  # Parameters used on the APIcasso that should be checked against
  # security measures
  def apicasso_parameters(hash = nil)
    (hash || params.to_unsafe_h).slice(:group, :resource, :nested, :sort, :include, :batch)
  end
end
