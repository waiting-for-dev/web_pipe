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

      class Unset < Dry::Struct::Value
        attribute :type, Types::Strict::Symbol
      end

      Env = Types::Strict::Hash
      Request = Types::Instance(::Rack::Request)
      Session = Types::Strict::Hash

      Scheme = Types::Strict::Symbol.enum(:http, :https)
      Method = Types::Strict::Symbol.enum(
        :get, :head, :post, :put, :delete, :connect, :options, :trace, :patch
      )
      Host = Types::Strict::String
      Ip = Types::Strict::String.optional
      Port = Types::Strict::Integer
      ScriptName = Types::Strict::String
      PathInfo = Types::Strict::String
      QueryString = Types::Strict::String
      RequestBody = Pipe::Types.Contract(:gets, :each, :read, :rewind)

      BaseUrl = Types::Strict::String
      Path = Types::Strict::String
      FullPath = Types::Strict::String
      Url = Types::Strict::String
      Params = Types::Strict::Hash

      Status = Types::Strict::Integer | Types::Unset
      ResponseBody = Pipe::Types.Contract(:each).
                       default([''].freeze)

      Headers = Types::Strict::Hash.
                  map(Types::Strict::String, Types::Strict::String).
                  default({}.freeze)

      Bag = Types::Strict::Hash.default({}.freeze)
    end
  end
end