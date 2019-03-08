require 'dry/types'
require 'dry/struct'

module WebPipe
  class Conn < Dry::Struct
    module Types
      include Dry::Types.module

      RequestMethod = Types::Strict::Symbol.enum(:get, :head, :post, :put, :delete, :connect, :options, :trace, :patch)
    end
  end
end