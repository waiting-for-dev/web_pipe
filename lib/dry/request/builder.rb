require 'dry/request/conn'

module Dry
  module Request
    class Builder < Module
      attr_reader :class_context

      def initialize
        @class_context = ClassContext.new
      end

      def included(klass)
        klass.extend(class_context)
        klass.include(InstanceContext.new(class_context))
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
            define_method(:plug) do |name, from:|
              steps << [name, from]
            end
          end
        end
      end

      class InstanceContext < Module
        attr_reader :steps

        def initialize(class_context)
          @steps = class_context.steps
        end

        def included(klass)
          define_call_method
        end

        private

        def define_call_method
          module_exec(steps) do |steps|
            define_method :call do |env|
              conn = Conn.new(env)

              steps.reduce(conn) { |prev_conn, step| step.last.call(prev_conn) }

              conn.rack_response
            end
          end
        end
      end
    end
  end
end