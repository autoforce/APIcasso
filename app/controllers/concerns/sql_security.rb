# frozen_string_literal: true

# This concern is used to check SQL injection
module SqlSecurity
  extend ActiveSupport::Concern

  included do
    prepend_before_action :klasses_allowed
    append_before_action :bad_request?
  end

  Rails.application.eager_load!
  DESCENDANTS_UNDERSCORED = ActiveRecord::Base.descendants.map do |descendant|
    descendant.to_s.underscore
  end.freeze

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

  # Check if request is a sql injection
  def sql_injection(klass)
    apicasso_parameters.each do |key, value|
      if key.to_sym == :group
        return false unless group_sql_safe?(klass, value)
      else
        return false unless parameters_sql_safe?(klass, value)
      end
    end
  end

  private

  # Check for SQL injection before requests and
  # raise a exception when find
  def bad_request?
    raise ActionController::BadRequest.new('Bad hacker, stop be bully or I will tell to your mom!') unless sql_injection(resource)
  end

  # Check for a bad request to be more secure
  def klasses_allowed
    raise ActionController::BadRequest.new('Bad hacker, stop be bully or I will tell to your mom!') unless descendants_included?
  end

  # Check if it's a descendant model allowed
  def descendants_included?
    DESCENDANTS_UNDERSCORED.include?(param_attribute.to_s.underscore)
  end

  # Get param to be compared
  def param_attribute
    representative_resource.singularize
  end

  def representative_resource
    (params[:nested] || params[:resource] || controller_name)
  end

  # Check if group params is safe for sql injection
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

  # Check if regular params is safe for sql injection
  def parameters_sql_safe?(klass, value)
    value.split(',').each do |param|
      return false unless safe_for_sql?(klass, param.gsub(/\A[+-]/, ''))
    end
    true
  end

  # Check if value for current class is valid for API consumption
  def safe_for_sql?(klass, value)
    klass.column_names.include?(value) ||
      DESCENDANTS_UNDERSCORED.include?(value.singularize) ||
      klass.new.respond_to?(value) ||
      klass.reflect_on_all_associations.map(&:name).include?(value)
  end

  def apicasso_parameters
    params.to_unsafe_h.slice(:group, :resource, :nested, :sort, :include)
  end
end
