# frozen_string_literal: true

require 'dry/types'
require 'dry/core/constants'

module WebPipe
  # Namespace for generic library types.
  module Types
    include Dry.Types()
    include Dry::Core::Constants

    Container = Interface(:[])
  end
end
