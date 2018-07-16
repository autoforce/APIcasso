# frozen_string_literal: true

module Apicasso
  # A model to abstract API access, with scope options, token generation, request limiting
  class Key < ApplicationRecord
    include Discard::Model
    before_create :generate_token

    private

    # Method that generates `SecureRandom.hex` as token until
    # an unique one has been acquired
    def generate_token
      loop do
        self.token = SecureRandom.hex
        break unless self.class.exists?(token: token)
      end
    end
  end
end
