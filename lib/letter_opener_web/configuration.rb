module LetterOpenerWeb
  class Configuration
    # Whether you enable authentication or not
    attr_accessor :authentication_enabled

    # The options for authentication
    # Now, only basic authentication is available
    attr_accessor :authentication_options
  end
end
