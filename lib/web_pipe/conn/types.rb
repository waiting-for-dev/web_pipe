require 'dry/types'
require 'dry/struct'
require 'rack/request'

module WebPipe
  class Conn < Dry::Struct
    module Types
      include Dry::Types.module

      EMPTY_STRING = ''

      module Rack
        Request = Types::Instance(::Rack::Request)
      end

      module Request
        Params = Types::Strict::Hash
        Headers = Types::Strict::Hash
        Method = Types::Strict::Symbol.enum(:get, :head, :post, :put, :delete, :connect, :options, :trace, :patch)
        ScriptName = Types::Strict::String.default(EMPTY_STRING)
        PathInfo = Types::Strict::String.default(EMPTY_STRING)
        QueryString = Types::Strict::String
        ServerName = Types::Strict::String
        ServerPort = Types::Strict::Integer
        BaseUrl = Types::Strict::String
        Scheme = Types::Strict::Symbol.enum(:http, :https)
      end
    end
  end
end