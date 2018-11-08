# frozen_string_literal: true

require 'swagger/blocks'

module Apicasso
  # This class is injected into `ActiveRecord` to enable Swagger docs to be
  # generated automatically based on schema and I18n definitions in your
  # own application.
  module ActiveRecordExtension
    extend ActiveSupport::Concern
    module ClassMethods
      def validated_attrs_for(validation)
        if validation.is_a?(String) || validation.is_a?(Symbol)
          klass = 'ActiveRecord::Validations::' \
                  "#{validation.to_s.camelize}Validator"
          validation = klass.constantize
        end
        validators.select { |v| v.is_a?(validation) }
                  .map(&:attributes)
                  .flatten
                  .map(&:to_sym)
      end

      def presence_validators?
        presence_validators.present?
      end

      def presence_validators
        validated_attrs_for(:presence)
      end
    end
  end
end

# Include the extension to avoid including on all files mannually
ActiveRecord::Base.send(:include, Apicasso::ActiveRecordExtension)
