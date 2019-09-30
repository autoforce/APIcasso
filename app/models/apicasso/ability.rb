# frozen_string_literal: true

module Apicasso
  # Ability to parse a scope object from Apicasso::Key
  class Ability
    include CanCan::Ability

    # Method that initializes CanCanCan with the scope of
    # permissions based on current key from request
    # @param key [Object] a key object by APIcasso to CanCanCan with ability
    def initialize(key)
      key ||= Apicasso::Key.new
      cannot :manage, :all
      cannot :read, :all
      key.scope&.each do |permission, klasses_clearances|
        build_permissions(permission: permission, clearance: klasses_clearances)
      end
    end

    def build_permissions(opts = {})
      permission = opts[:permission].to_sym
      clearances = opts[:clearance]
      # To have full read access to the whole APIcasso just set a
      # true key scope operation.
      # Usage:
      # To have full read access to the system the scope would be:
      # => `{read: true}`
      if clearances == true
        can permission, :all
      else
        clearances.to_h.each do |klass, clearance|
          klass_module = klass.underscore.singularize.to_sym
          klass = klass.classify.constantize
          can permission, klass_module
          if clearance == true
            # Usage:
            # To have a key reading all channels and all accouts
            # you would have a scope:
            # => `{read: {channel: true, accout: true}}`
            can permission, klass
          else
            clear_for(permission, klass, clearance)
          end
        end
      end
    end
    
    # Given a permission, a class and a hash of clearance conditions
    # builds permissions for the current ability.
    # Usage:
    # To have a key reading all banners from a channel with id 999
    # you would have a scope:
    # => `{read: {banner: {owner_id: [999]}}}`
    def clear_for(permission, klass, clearance)
      clearance.to_h.each do |by_field, values|
        can permission, klass, by_field.to_sym => values
      end
    end
  end
end
