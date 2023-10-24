# frozen_string_literal: true

require 'hanami/view'

module WebPipe
  module HanamiView
    # Noop context class for Hanami::View used by default.
    class Context < Hanami::View::Context
      def initialize(**_kwargs)
        super()
      end
    end
  end
end
