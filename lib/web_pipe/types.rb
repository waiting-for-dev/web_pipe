# frozen_string_literal: true

require 'dry/types'
require 'dry/core/constants'

module WebPipe
  # Namespace for generic types.
  module Types
    include Dry.Types()
    include Dry::Core::Constants
  end
end
