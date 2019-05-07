require 'dry/types'
require 'rack/request'
require 'web_pipe/types'

module WebPipe
  module ConnSupport
    # Types used for {Conn} struct.
    #
    # Implementation self-describes them, but you can look at {Conn}
    # attributes for documentation.
    module Types
      include Dry.Types()

      Env = Strict::Hash
      Request = Instance(::Rack::Request)

      Scheme = Strict::Symbol.enum(:http, :https)
      Method = Strict::Symbol.enum(
        :get, :head, :post, :put, :delete, :connect, :options, :trace, :patch
      )
      Host = Strict::String
      Ip = Strict::String.optional
      Port = Strict::Integer
      ScriptName = Strict::String
      PathInfo = Strict::String
      QueryString = Strict::String
      RequestBody = WebPipe::Types.Contract(:gets, :each, :read, :rewind)

      BaseUrl = Strict::String
      Path = Strict::String
      FullPath = Strict::String
      Url = Strict::String
      Params = Strict::Hash

      Status = Strict::Integer.
                 default(200).
                 constrained(gteq: 100, lteq: 599)
      ResponseBody = WebPipe::Types.Contract(:each).
                       default([''].freeze)

      Headers = Strict::Hash.
                  map(Strict::String, Strict::String).
                  default({}.freeze)

      Bag = Strict::Hash.
              map(Strict::Symbol, Strict::Any).
              default({}.freeze)
    end
  end
end