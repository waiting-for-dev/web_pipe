require 'dry/struct'
require 'web_pipe/conn/types'
require 'web_pipe/conn/builder'

module WebPipe
  class Conn < Dry::Struct
    attr_accessor :resp_body

    attribute :request do
      # Rack
      attribute :rack_env, Types::Request::RackEnv
      attribute :rack_request, Types::Request::RackRequest
      # Request
      attribute :scheme, Types::Request::Scheme
      attribute :req_method, Types::Request::Method
      attribute :host, Types::Request::Host
      attribute :ip, Types::Request::Ip
      attribute :port, Types::Request::Port
      attribute :script_name, Types::Request::ScriptName
      attribute :path_info, Types::Request::PathInfo
      attribute :query_string, Types::Request::QueryString
      attribute :headers, Types::Request::Headers
      # Redundant
      attribute :base_url, Types::Request::BaseUrl
      attribute :params, Types::Request::Params

      def fetch_params
        Builder.call(rack_env).new(request: new(params: rack_request.params))
      end
    end

    def put_response_body(value)
      @resp_body = value
      self
    end

    def rack_response
      [200, {}, [@resp_body]]
    end

    def taint
      dirty = DirtyConn.new(attributes)
      dirty.resp_body = resp_body
      dirty
    end
  end

  class CleanConn < Conn; end
  class DirtyConn < Conn; end
end