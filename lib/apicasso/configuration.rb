module Apicasso
  # This class exposes the settable attributes of the gem
  class Configuration
    attr_writer :origins, :headers, :resource, :credentials, :methods,
                :max_age, :expose, :if, :vary

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
    end
  end
end
