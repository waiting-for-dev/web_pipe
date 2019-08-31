# frozen_string_literal: true

require 'web_pipe/types'
require 'web_pipe/dsl/dsl_context'

module WebPipe
  module DSL
    # Defines the DSL and keeps the state for the pipe.
    #
    # This is good to be an instance because it keeps the
    # configuration (state) for the pipe class: the container
    # configured on initialization and both rack middlewares and plugs
    # added through the DSL {DSLContext}.
    #
    # As the pipe is extended with an instance of this class, methods
    # that are meant to be class methods in the pipe are defined as
    # singleton methods of the instance.
    #
    # @api private
    class ClassContext < Module
      # Methods to be imported from the {DSLContext}.
      DSL_METHODS = %i[middleware_specifications use plugs plug compose].freeze

      # @!attribute [r] container
      # @return [Types::Container[]]
      attr_reader :container

      # @return [DSLContext]
      attr_reader :dsl_context

      def initialize(container:)
        @container = Types::Container[container]
        @dsl_context = DSLContext.new([], [])
        define_container
        define_dsl
      end

      private

      def define_container
        module_exec(container) do |container|
          define_method(:container) do
            container
          end
        end
      end

      def define_dsl
        DSL_METHODS.each do |method|
          module_exec(dsl_context) do |dsl_context|
            define_method(method) do |*args, &block|
              dsl_context.method(method).call(*args, &block)
            end
          end
        end
      end
    end
  end
end
