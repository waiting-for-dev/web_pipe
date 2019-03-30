require 'dry/types'
require 'rack/request'

module WebPipe
  module Conn
    module Types
      include Dry::Types.module

      module Rack
        Request = Types::Instance(::Rack::Request)
        Env = Types::Strict::Hash
      end

      module Request
        class Unfetched < Dry::Struct::Value
          attribute :type, Types::Strict::Symbol
        end

        Scheme = Types::Strict::Symbol.enum(:http, :https)
        Method = Types::Strict::Symbol.enum(:get, :head, :post, :put, :delete, :connect, :options, :trace, :patch)
        Host = Types::Strict::String
        Ip = Types::Strict::String.optional
        Port = Types::Strict::Integer
        ScriptName = Types::Strict::String
        PathInfo = Types::Strict::String
        QueryString = Types::Strict::String

        Headers = Types::Strict::Hash | Types::Request::Unfetched

        BaseUrl = Types::Strict::String | Types::Request::Unfetched
        Path = Types::Strict::String | Types::Request::Unfetched
        FullPath = Types::Strict::String | Types::Request::Unfetched
        Url = Types::Strict::String | Types::Request::Unfetched
        Params = Types::Strict::Hash | Types::Request::Unfetched

        Body = Types::Any | Types::Request::Unfetched

        Cookies = Types::Strict::Hash | Types::Request::Unfetched
      end

      module Response
        class Unset < Dry::Struct::Value
          attribute :type, Types::Strict::Symbol
        end

        Status = Types::Strict::Integer | Types::Response::Unset
        Body = Types::Strict::Array.of(Types::Strict::String).default([''])
        Headers = Types::Strict::Hash.default({})
      end
    end
  end
end