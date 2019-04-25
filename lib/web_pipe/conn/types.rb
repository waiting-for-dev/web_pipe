require 'dry/types'
require 'rack/request'

module WebPipe
  module Conn
    module Types
      include Dry.Types()

      class Unfetched < Dry::Struct::Value
        attribute :type, Types::Strict::Symbol
      end

      class Unset < Dry::Struct::Value
        attribute :type, Types::Strict::Symbol
      end

      Env = Types::Strict::Hash
      Requesting = Types::Instance(::Rack::Request)

      Scheme = Types::Strict::Symbol.enum(:http, :https)
      Method = Types::Strict::Symbol.enum(:get, :head, :post, :put, :delete, :connect, :options, :trace, :patch)
      Host = Types::Strict::String
      Ip = Types::Strict::String.optional
      Port = Types::Strict::Integer
      ScriptName = Types::Strict::String
      PathInfo = Types::Strict::String
      QueryString = Types::Strict::String

      RequestHeaders = Types::Strict::Hash | Types::Unfetched

      BaseUrl = Types::Strict::String | Types::Unfetched
      Path = Types::Strict::String | Types::Unfetched
      FullPath = Types::Strict::String | Types::Unfetched
      Url = Types::Strict::String | Types::Unfetched
      Params = Types::Strict::Hash | Types::Unfetched

      RequestBody = Types::Any | Types::Unfetched

      Session = Types::Strict::Hash | Types::Unfetched

      Status = Types::Strict::Integer | Types::Unset
      ResponseBody = Types::Strict::Array.of(Types::Strict::String).default([''].freeze)
      ResponseHeaders = Types::Strict::Hash.default({}.freeze)

      Bag = Types::Strict::Hash.default({}.freeze)
    end
  end
end