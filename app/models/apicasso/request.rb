# frozen_string_literal: true

module Apicasso
  # A model to abstract API access, with scope options, token generation, request limiting
  class Request < Apicasso::ApplicationRecord
    belongs_to :api_key, class_name: 'Apicasso::Key'
  end
end
