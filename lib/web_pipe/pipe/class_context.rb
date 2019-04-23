require 'web_pipe'
require 'web_pipe/pipe/dsl'

module WebPipe
  module Pipe
    # Defines the DSL and keeps the state for the pipe.
    #
    # This is good to be an instance because it keeps the
    # configuration (state) for the pipe class: the container
    # configured on initialization and both rack middlewares and plugs
    # added through the DSL.
    #
    # As the pipe is extended with an instance of this class, methods
    # that are meant to be class methods in the pipe are defined as
    # singleton methods of the instance.
    #
    # @private
    class ClassContext < Module
      attr_reader :container
      attr_reader :dsl

      DSL_METHODS = %i[middlewares use plugs plug].freeze

      def initialize(container:)
        @container = container
        @dsl = DSL.new([], [])
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
          module_exec(dsl) do |dsl|
            define_method(method) do |*args|
              dsl.method(method).(*args)
            end
          end
        end
      end
    end
  end
end