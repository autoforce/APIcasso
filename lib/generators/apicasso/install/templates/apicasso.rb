Apicasso.configure do |config|
  # Origins can be specified as a string, a regular expression,
  # or as '*' to allow all origins.
  # Origin response header indicates whether the response can be
  # shared with requesting code from the given origin.
  config.origins = '*'

  # A Resource path can be specified as exact string match (/path/to/file.txt)
  # or with a '*' wildcard (/all/files/in/*).
  # To include all of a directory's files and the files in its subdirectories,
  # use this form: /assets/**/*.
  config.resource = '*'

  # The HTTP methods allowed for the resource.
  # Can be a string or array or :any
  config.headers = :any

  # Sets the Access-Control-Allow-Credentials response header.
  # If a wildcard (*) origin is specified, this option cannot be set to true.
  # Can be a boolean, default: false
  config.credentials = '*'

  # Sets the Access-Control-Max-Age response header.
  # The Access-Control-Max-Age response header indicates how long the results
  # of a preflight request (that is the information contained in the
  # Access-Control-Allow-Methods and Access-Control-Allow-Headers headers)
  # can be cached.
  # Must be a number
  config.max_age = 1728000

  # The Access-Control-Allow-Methods response header specifies the method or
  # methods allowed when accessing the resource in response to a request.
  # Cam be a string or array or :any
  config.methods = [:get, :post, :delete, :put, :patch, :options]

  # The Vary HTTP response header determines how to match future request headers
  # to decide whether a cached response can be used rather than requesting a
  # fresh one from the origin server. It is used by the server to indicate which
  # headers it used when selecting a representation of a resource in a content
  # negotiation algorithm.
  # Can be a string or array
  config.vary = nil

  # The Access-Control-Expose-Headers response header indicates which headers
  # can be exposed as part of the response by listing their names.
  # Can be a string or array
  config.expose = nil

  # If the result of the proc is true, will process the request as
  # a valid CORS request.
  # Must be a Proc
  config.if = nil
end
