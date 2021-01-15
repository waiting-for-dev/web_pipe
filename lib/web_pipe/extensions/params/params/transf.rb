# frozen_string_literal: true

require 'dry/transformer'

module WebPipe
  module Params
    # Parameter transformations from dry-transformer.
    module Transf
      extend Dry::Transformer::Registry

      import Dry::Transformer::HashTransformations

      def self.id(params)
        params
      end
    end
  end
end
