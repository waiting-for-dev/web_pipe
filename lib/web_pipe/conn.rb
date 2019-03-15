require 'dry/struct'
require 'web_pipe/conn/types'

module WebPipe
  class Conn < Dry::Struct
    attr_accessor :resp_body

    attribute :request do
      attribute :params, Types::Request::Params
      attribute :headers, Types::Request::Headers
      attribute :req_method, Types::Request::Method
      attribute :script_name, Types::Request::ScriptName
      attribute :path_info, Types::Request::PathInfo
      attribute :query_string, Types::Request::QueryString
      attribute :server_name, Types::Request::ServerName
      attribute :server_port, Types::Request::ServerPort
      attribute :scheme, Types::Request::Scheme
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