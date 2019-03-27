require 'dry/types'
require 'rack/request'

module WebPipe
  class Conn < Dry::Struct
    module Types
      include Dry::Types.module

      EMPTY_STRING = ''

      module Request
        Unfetched = ::Class.new(Dry::Struct::Value) do
          attribute :type, Types::Strict::Symbol
        end

        RackRequest = Types::Instance(::Rack::Request)
        RackEnv = Types::Strict::Hash
        Params = Types::Request::Unfetched | Types::Strict::Hash
        Headers = Types::Strict::Hash
        Method = Types::Strict::Symbol.enum(:get, :head, :post, :put, :delete, :connect, :options, :trace, :patch)
        ScriptName = Types::Strict::String.default(EMPTY_STRING)
        PathInfo = Types::Strict::String.default(EMPTY_STRING)
        QueryString = Types::Strict::String
        Host = Types::Strict::String
        Port = Types::Strict::Integer
        BaseUrl = Types::Strict::String
        Scheme = Types::Strict::Symbol.enum(:http, :https)
      end
    end
  end
end