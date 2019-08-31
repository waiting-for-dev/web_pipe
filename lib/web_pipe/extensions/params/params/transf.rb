# frozen_string_literal: true

require 'transproc'

module WebPipe
  module Params
    module Transf
      extend Transproc::Registry

      import Transproc::HashTransformations

      def self.id(params)
        params
      end
    end
  end
end
