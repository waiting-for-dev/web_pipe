require 'dry/request/conn'
require 'dry/request/resolver'
require 'dry/monads/result'

module Dry
  module Request
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

      class ClassContext < Module
        attr_reader :steps
        attr_reader :container

        def initialize(container:)
          @steps = []
          @container = container
          define_steps
          define_container
          define_plug_method
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
      end

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
end