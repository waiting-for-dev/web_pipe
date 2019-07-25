require 'dry/types'
require 'rack/request'

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
      RequestBody = Interface(:gets, :each, :read, :rewind)

      BaseUrl = Strict::String
      Path = Strict::String
      FullPath = Strict::String
      Url = Strict::String
      Params = Strict::Hash

      Status = Strict::Integer.
                 default(200).
                 constrained(gteq: 100, lteq: 599)
      ResponseBody = Interface(:each).default { [''] }

      Headers = Strict::Hash.
                  map(Strict::String, Strict::String).
                  default { {} }

      Bag = Strict::Hash.
              map(Strict::Symbol, Strict::Any).
              default { {} }
    end
  end
end