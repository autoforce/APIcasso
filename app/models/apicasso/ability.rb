# frozen_string_literal: true

module Apicasso
  # Ability to parse a scope object from Apicasso::Key
  class Ability
    include CanCan::Ability

    def initialize(key)
      key ||= Apicasso::Key.new
      cannot :manage, :all
      cannot :read, :all
      key.scope.each do |permission, klasses_clearances|
        klasses_clearances.each do |klass, clearance|
          if clearance == true
            # Usage:
            # To have a key reading all channels and all accouts
            # you would have a scope:
            # => `{read: {channel: true, accout: true}}`
            can permission.to_sym, klass.underscore.to_sym
            can permission.to_sym, klass.classify.constantize
          elsif clearance.class == Hash
            # Usage:
            # To have a key reading all banners from a channel with id 999
            # you would have a scope:
            # => `{read: {banner: {owner_id: [999]}}}`
            can permission.to_sym,
                klass.underscore.to_sym
            clearance.each do |by_field, values|
              can permission.to_sym,
                  klass.classify.constantize,
                  by_field.to_sym => values
            end
          end
        end
      end
    end
  end
end
