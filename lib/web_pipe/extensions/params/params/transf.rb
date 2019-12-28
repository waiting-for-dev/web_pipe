# frozen_string_literal: true

require 'dry/transformer'

module WebPipe
  module Params
    module Transf
      extend Dry::Transformer::Registry

      import Dry::Transformer::HashTransformations

      def self.id(params)
        params
      end
    end
  end
end
