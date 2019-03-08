require 'dry/types'
require 'dry/struct'

module WebPipe
  class Conn < Dry::Struct
    module Types
      include Dry::Types.module
    end
  end
end