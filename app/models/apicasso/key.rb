# frozen_string_literal: true

require 'securerandom'
module Apicasso
  # A model to abstract API access, with scope options, token generation, request limiting
  class Key < Apicasso::ApplicationRecord
    before_create :set_auth_token

    private

    # Method that generates `SecureRandom.uuid` as token until
    # an unique one has been acquired
    def set_auth_token
      loop do
        self.token = generate_auth_token
        break unless self.class.exists?(token: token)
      end
    end

    # RFC4122 style token
    def generate_auth_token
      SecureRandom.uuid.delete('-')
    end
  end
end
