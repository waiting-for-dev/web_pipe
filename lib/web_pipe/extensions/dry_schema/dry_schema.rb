# frozen_string_literal: true

require 'web_pipe'

WebPipe.load_extensions(:params)

# :nodoc:
module WebPipe
  # Integration with `dry-schema` validation library.
  #
  # This extension provides a simple integration with `dry-schema`
  # library to streamline param sanitization.
  #
  # On its own, the library just provides with a
  # `Conn#sanitized_params` method, which will return what is set into
  # config's `:sanitized_params` key.
  #
  # This key in config is what will be populated by `SanitizeParams` plug. It
  # takes as arguments the `dry-schema` schema that will be applied to
  # `Conn#params` and an error handler taking `Conn` instance and the validation
  # result:
  #
  # @example
  #  require 'web_pipe'
  #
  #  WebPipe.load_extensions(:dry_schema)
  #
  #  class App
  #    include WebPipe
  #
  #    Schema = Dry::Schema.Params do
  #      required(:name).filled(:string)
  #    end
  #
  #    plug :sanitize_params, WebPipe::Plugs::SanitizeParams.(
  #      Schema,
  #      ->(conn, result) { ... }
  #    )
  #    plug(:do_something_with_params) do |conn|
  #      DB.persist(:entity, conn.sanitized_params)
  #    end
  #  end
  #
  # A common workflow is applying the same handler for all param
  # sanitization across your application. This can be achieved configuring
  # a `:param_sanitization_handler` in a upstream operation which can
  # be composed downstream from any number of pipes. `SanitizeParams`
  # will used configured handler if none is injected as
  # argument.
  #
  # @example
  #  class App
  #    plug :sanitization_handler, ->(conn, result) { ... }
  #  end
  #
  #  class Subapp
  #    Schema = Dry::Schema.Params { ... }
  #
  #    plug :app, App.new
  #    plug :sanitize_params, WebPipe::Plugs::SanitizeParams.call(Schema)
  #  end
  #
  # @see https://dry-rb.org/gems/dry-schema/
  module DrySchema
    SANITIZED_PARAMS_KEY = :sanitized_params

    def sanitized_params
      fetch_config(SANITIZED_PARAMS_KEY)
    end
  end

  Conn.include(DrySchema)
end
