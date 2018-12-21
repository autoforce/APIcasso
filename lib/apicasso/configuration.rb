module Apicasso
  # This class exposes the settable attributes of the gem
  class Configuration
    attr_accessor :origins, :headers, :resource, :credentials, :methods,
                  :max_age, :expose, :if, :vary, :model_definitions_excluded

    def initialize
      @origins = nil
      @headers = nil
      @resource = nil
      @credentials = nil
      @methods = nil
      @max_age = nil
      @expose = nil
      @if = nil
      @vary = nil
      @model_definitions_excluded = []
    end
  end
end
