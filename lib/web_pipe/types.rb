require 'dry/types'

module WebPipe
  # Namespace for generic library types.
  module Types
    include Dry.Types()

    Container = Interface(:[])
  end
end