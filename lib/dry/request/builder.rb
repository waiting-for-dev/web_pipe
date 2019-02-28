require 'dry/request/conn'
require 'dry/request/resolver'
require 'dry/monads/result'

module Dry
  module Request
    class Builder < Module
      EMPTY_CONTAINER = {}

      attr_reader :class_context
      attr_reader :container

      def initialize(container: EMPTY_CONTAINER)
        @class_context = ClassContext.new
        @container = container
      end

      def included(klass)
        klass.extend(class_context)
        klass.include(InstanceContext.new(class_context, container))
      end

      class ClassContext < Module
        attr_reader :steps

        def initialize
          @steps = []
          define_plug_method
        end

        private

        def define_plug_method
          module_exec(steps) do |steps|
            define_method(:plug) do |name, with:|
              steps << [name, with]
            end
          end
        end
      end

      class InstanceContext < Module
        attr_reader :steps
        attr_reader :container

        def initialize(class_context, container)
          @steps = class_context.steps
          @container = container
        end

        def included(klass)
          klass.attr_reader :steps
          klass.attr_reader :container
          klass.include Dry::Monads::Result::Mixin
          define_initialize_method
          define_call_method
        end

        private

        def define_initialize_method
          module_exec(steps, container) do |steps, container|
            define_method :initialize do |**kwargs|
              @steps = steps.map do |(name, op)|
                kwargs.has_key?(name) ? [name, kwargs[name]] : [name, op]
              end
              @container = container
            end
          end
        end

        def define_call_method
          module_exec do
            define_method :call do |env|
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
  end
end