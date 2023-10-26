# frozen_string_literal: true

require "web_pipe"
require "web_pipe/types"

WebPipe.load_extensions(:params)

module WebPipe
  # See the docs for the extension linked from the README.
  module RouterParams
    ROUTER_PARAM_KEY = "router.params"

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
