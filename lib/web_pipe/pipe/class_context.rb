require 'web_pipe'

module WebPipe
  module Pipe
    # Defines the DSL and keeps the state for the pipe.
    #
    # This needs to be an instance because it keeps the
    # configuration (state) for the pipe class: the container and
    # the plugs that are added through the DSL.
    #
    # As the pipe is extended with an instance of this class, the
    # methods that are meant to be class methods in the pipe are
    # defined as singleton methods of the instance.
    #
    # @private
    class ClassContext < Module
      attr_reader :middlewares
      attr_reader :plugs
      attr_reader :container
      
      def initialize(container:)
        @middlewares = []
        @plugs = []
        @container = container
        define_middlewares
        define_plugs
        define_container
        define_use
        define_plug
        define_compose
      end
      
      private

      def define_middlewares
        module_exec(middlewares) do |middlewares|
          define_method(:middlewares) do
            middlewares
          end
        end
      end

      def define_plugs
        module_exec(plugs) do |plugs|
          define_method(:plugs) do
            plugs
          end
        end
      end
      
      def define_container
        module_exec(container) do |container|
          define_method(:container) do
            container
          end
        end
      end

      def define_use
        module_exec(middlewares) do |middlewares|
          define_method(:use) do |middleware, *args|
            middlewares << [middleware, args]
          end
        end
      end
      
      def define_plug
        module_exec(plugs) do |plugs|
          define_method(:plug) do |name, with: nil|
            plugs << [name, with]
          end
        end
      end
      
      def define_compose
        module_exec(plugs, container) do |plugs, self_container|
          define_method(:>>) do |pipe, container: self_container|
            Class.new do
              include WebPipe.(container: container)
              
              (plugs + pipe.plugs).each do |(name, operation)|
                plug name, with: operation
              end
            end
          end
        end
      end
    end
  end
end