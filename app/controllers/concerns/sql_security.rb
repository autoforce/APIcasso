# frozen_string_literal: true

# This concern is used to check SQL injection
module SqlSecurity
  extend ActiveSupport::Concern

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
