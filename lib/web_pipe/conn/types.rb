require 'dry/types'
require 'dry/struct'

module WebPipe
  class Conn < Dry::Struct
    module Types
      include Dry::Types.module

      module Request
        Params = Types::Strict::Hash
        Headers = Types::Strict::Hash
        Method = Types::Strict::Symbol.enum(:get, :head, :post, :put, :delete, :connect, :options, :trace, :patch)
      end
    end
  end
end