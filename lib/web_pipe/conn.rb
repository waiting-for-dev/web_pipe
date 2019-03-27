require 'dry/struct'
require 'web_pipe/conn/types'
require 'web_pipe/conn/builder'

module WebPipe
  class Conn < Dry::Struct
    attr_accessor :resp_body

    attribute :request do
      ID = -> (x) { x }

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
      # URL redundancy
      attribute :base_url, Types::Request::BaseUrl
      attribute :path, Types::Request::Path
      attribute :full_path, Types::Request::FullPath
      attribute :url, Types::Request::Url
      attribute :params, Types::Request::Params
      # Body
      attribute :body, Types::Request::Body

      def fetch_redundants
        new_parent(
          base_url: rack_request.base_url,
          path: rack_request.path,
          full_path: rack_request.fullpath,
          url: rack_request.url,
          params: rack_request.params
        )
      end

      def fetch_body(parser = ID)
        new_parent(
          body: parser.(rack_request.body)
        )
      end

      private

      def new_parent(attrs)
        Builder.call(rack_env).new(request: new(attrs))
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