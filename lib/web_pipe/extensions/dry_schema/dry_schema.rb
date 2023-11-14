# frozen_string_literal: true

WebPipe.load_extensions(:params)

# :nodoc:
module WebPipe
  # See the docs for the extension linked from the README.
  module DrySchema
    SANITIZED_PARAMS_KEY = :sanitized_params

    def sanitized_params
      fetch_config(SANITIZED_PARAMS_KEY)
    end
  end

  Conn.include(DrySchema)
end
