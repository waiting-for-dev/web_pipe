# frozen_string_literal: true

require 'web_pipe/types'
require 'web_pipe/dsl/class_context'
require 'web_pipe/dsl/instance_methods'

module WebPipe
  module DSL
    # When an instance of it is included in a module, the module
    # extends a {ClassContext} instance and includes
    # {InstanceMethods}.
    #
    # @api private
    class Builder < Module
      # Container with nothing registered.
      EMPTY_CONTAINER = Types::EMPTY_HASH

      # @!attribute [r] container
      # @return [Types::Container[]]
      attr_reader :container

      # @return [ClassContext]
      attr_reader :class_context

      def initialize(container: EMPTY_CONTAINER)
        @container = Types::Container[container]
        @class_context = ClassContext.new(container: container)
      end

      def included(klass)
        klass.extend(class_context)
        klass.include(InstanceMethods)
      end
    end
  end
end
