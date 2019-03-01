require 'web_pipe/conn'
require 'web_pipe/resolver'
require 'dry/monads/result'

module WebPipe
  # When an instance of it is included in a module, the module
  # extends a `ClassContext` instance and includes
  # `InstanceMethods`.
  #
  # @private
  class Builder < Module
    EMPTY_CONTAINER = {}
 
    attr_reader :class_context
 
    def initialize(container: EMPTY_CONTAINER)
      @class_context = ClassContext.new(container: container)
    end
 
    def included(klass)
      klass.extend(class_context)
      klass.include(InstanceMethods)
    end
 
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
      attr_reader :steps
      attr_reader :container
 
      def initialize(container:)
        @steps = []
        @container = container
        define_steps
        define_container
        define_plug_method
        define_compose_method
      end
 
      private
 
      def define_steps
        module_exec(steps) do |steps|
          define_method(:steps) do
            steps
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
 
      def define_plug_method
        module_exec(steps) do |steps|
          define_method(:plug) do |name, with:|
            steps << [name, with]
          end
        end
      end
 
      def define_compose_method
        module_exec(steps, container) do |steps, self_container|
          define_method(:>>) do |pipe, container: self_container|
            Class.new do
              include WebPipe.(container: container)
 
              (steps + pipe.steps).each do |(name, operation)|
                plug name, with: operation
              end
            end
          end
        end
      end
    end
 
    # Instance methods for the pipe.
    #
    # The pipe state can be accessed through the pipe class, which
    # has been configured through `ClassContext`.
    #
    # @private
    module InstanceMethods
      attr_reader :steps
      attr_reader :container
 
      include Dry::Monads::Result::Mixin
 
      def initialize(**kwargs)
        @steps = self.class.steps.map do |(name, op)|
          kwargs.has_key?(name) ? [name, kwargs[name]] : [name, op]
        end
        @container = self.class.container
      end
 
      def call(env)
        conn = Success(CleanConn.new(env))
        resolver = Resolver.new(container)
 
        last_conn = steps.reduce(conn) do |prev_conn, (_name, step)|
          prev_conn.bind do |c|
            result = resolver.(step).(c)
            case result
            when CleanConn
              Success(result)
            when DirtyConn
              Failure(result)
            else
              raise RuntimeError
            end
          end
        end
 
        case last_conn
        when Dry::Monads::Success
          last_conn.success.rack_response
        when Dry::Monads::Failure
          last_conn.failure.rack_response
        end
      end
    end
  end
end