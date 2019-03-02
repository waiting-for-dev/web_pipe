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
      attr_reader :plugs
      attr_reader :container
 
      def initialize(container:)
        @plugs = []
        @container = container
        define_plugs
        define_container
        define_plug
        define_compose
      end
 
      private
 
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
 
    # Instance methods for the pipe.
    #
    # The pipe state can be accessed through the pipe class, which
    # has been configured through `ClassContext`.
    #
    # @private
    module InstanceMethods
      attr_reader :plugs
      attr_reader :container
      attr_reader :resolver
 
      include Dry::Monads::Result::Mixin
 
      def initialize(**kwargs)
        @plugs = self.class.plugs.map do |(name, op)|
          kwargs.has_key?(name) ? [name, kwargs[name]] : [name, op]
        end
        @container = self.class.container
        @resolver = Resolver.new(container, self)
      end
 
      def call(env)
        conn = Success(CleanConn.new(env))
 
        last_conn = plugs.reduce(conn) do |prev_conn, (name, plug)|
          prev_conn.bind do |c|
            result = resolver.(name, plug).(c)
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