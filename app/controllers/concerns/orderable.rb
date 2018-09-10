# frozen_string_literal: true

# This concern is used to provide abstract ordering based on `params[:sort]`
module Orderable
  extend ActiveSupport::Concern
  SORT_ORDER = { '+' => :asc, '-' => :desc }.freeze

  # A list of the param names that can be used for ordering the model list
  def ordering_params(params)
    # For example it retrieves a list of orders in descending order of total_value.
    # Within a specific total_value, older orders are ordered first
    #
    # GET /orders?sort=-total_value,created_at
    # ordering_params(params) # => { total_value: :desc, created_at: :asc }
    #
    # Usage:
    # Order.order(ordering_params(params))
    ordering = {}
    params[:sort].try(:split, ',').try(:each) do |attr|
      parsed_attr = parse_attr attr
      if model.attribute_names.include?(parsed_attr)
        ordering[parsed_attr] = SORT_ORDER[parse_sign attr]
      end
    end
    ordering
  end

  private

  # Parsing of attributes to avoid empty starts in case browser passes "+" as " "
  def parse_attr(attr)
    return attr.gsub(/^\ (.*)/, '\1') if attr.starts_with?(' ')
    return attr[1..-1] if attr.starts_with?('+') || attr.starts_with?('-')
    attr
  end

  # Ordering sign parse, which separates
  def parse_sign(attr)
    attr =~ /\A[+-]/ ? attr.slice!(0) : '+'
  end

  def model
    (params[:resource] || params[:nested] || controller_name).classify.constantize
  end
end
