# frozen_string_literal: true

require 'web_pipe'
require 'web_pipe/types'

WebPipe.load_extensions(:params)

module WebPipe
  # Adds a transformation to merge router params into {Conn#params}.
  #
  # This extension gives an opportunity for rack routers to modify
  # {Conn#params} hash. This is useful so that they can provide *route
  # parameters*, which are typically rendered as variables in routes
  # definitions (e.g.: `/user/:id/edit`).
  #
  # It adds a `:router_params` transformation that, when used, will
  # merged env's `router.params` in {Conn#params} hash. Choosing this
  # name automatically integrates with `hanami-router`.
  #
  # When using this extension, `:params` extension is automatically enabled.
  #
  # @example
  #   require 'web_pipe'
  #
  #   WebPipe.load_extensions(:router_params)
  #
  #   class MyApp
  #     include WebPipe
  #
  #     plug :config
  #     plug :get_params
  #
  #     private
  #
  #     def config(conn)
  #       conn.add_config(:param_transformation, [:router_params])
  #     end
  #
  #     def get_params(conn)
  #       # http://example.com/users/1/edit
  #       conn.params #=> { id: 1 }
  #       conn
  #     end
  #  end
  #
  # @see WebPipe::Params
  # @see https://github.com/hanami/router#string-matching-with-variables
  module RouterParams
    ROUTER_PARAM_KEY = 'router.params'

    # @param params [Hash]
    # @param conn [WebPipe::Conn]
    #
    # @return [Hash]
    def self.call(params, conn)
      params.merge(conn.env.fetch(ROUTER_PARAM_KEY, Types::EMPTY_HASH))
    end

    WebPipe::Params::Transf.register(:router_params, method(:call))
  end
end
