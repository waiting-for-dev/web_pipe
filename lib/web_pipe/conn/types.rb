require 'dry/types'
require 'rack/request'
require 'web_pipe/pipe/types'

module WebPipe
  module Conn
    # Types used for {WebPipe::Conn} struct.
    #
    # Implementation self-describes them, but see {Conn::Struct}
    # attributes for intention documentation.
    module Types
      include Dry.Types()

      class Unfetched < Dry::Struct::Value
        attribute :type, Types::Strict::Symbol
      end

      class Unset < Dry::Struct::Value
        attribute :type, Types::Strict::Symbol
      end

      Env = Types::Strict::Hash
      Request = Types::Instance(::Rack::Request)
      Session = Types::Strict::Hash | Types::Unfetched

      Scheme = Types::Strict::Symbol.enum(:http, :https)
      Method = Types::Strict::Symbol.enum(:get, :head, :post, :put, :delete, :connect, :options, :trace, :patch)
      Host = Types::Strict::String
      Ip = Types::Strict::String.optional
      Port = Types::Strict::Integer
      ScriptName = Types::Strict::String
      PathInfo = Types::Strict::String
      QueryString = Types::Strict::String

      BaseUrl = Types::Strict::String | Types::Unfetched
      Path = Types::Strict::String | Types::Unfetched
      FullPath = Types::Strict::String | Types::Unfetched
      Url = Types::Strict::String | Types::Unfetched
      Params = Types::Strict::Hash | Types::Unfetched

      RequestBody = Pipe::Types.Contract(:gets, :each, :read, :rewind)

      Status = Types::Strict::Integer | Types::Unset
      ResponseBody = Types::Strict::Array.
                       of(Types::Strict::String).
                       default([''].freeze)

      Headers = Types::Strict::Hash.
                  map(Types::Strict::String, Types::Strict::String).
                  default({}.freeze)

      Bag = Types::Strict::Hash.default({}.freeze)
    end
  end
end