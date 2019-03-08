require 'dry/struct'
require 'web_pipe/conn/types'

module WebPipe
  class Conn < Dry::Struct
    attr_accessor :resp_body

    attribute :request do
      attribute :params, Types::Strict::Hash
      attribute :headers, Types::Strict::Hash
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