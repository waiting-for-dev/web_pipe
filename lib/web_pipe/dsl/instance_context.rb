# frozen_string_literal: true

require "web_pipe/pipe"

module WebPipe
  module DSL
    # @api private
    class InstanceContext < Module
      PIPE_METHODS = %i[
        call middlewares operations to_proc to_middlewares
      ].freeze

      attr_reader :container, :class_context

      def initialize(container:, class_context:)
        @container = container
        @class_context = class_context
        super()
      end

      def included(klass)
        klass.include(dynamic_module(class_context.ast, container))
      end

      private

      def dynamic_module(ast, container)
        Module.new.tap do |mod|
          define_initialize(mod, ast, container)
          define_pipe_methods(mod)
        end
      end

      # rubocop:disable Metrics/MethodLength
      def define_initialize(mod, ast, container)
        mod.define_method(:initialize) do |plugs: {}, middlewares: {}, **kwargs|
          acc = Pipe.new(container: container, context: self)
          @pipe = ast.reduce(acc) do |pipe, node|
            method, args, kwargs, block = node
            if block
              pipe.send(method, *args, **kwargs, &block)
            else
              pipe.send(method, *args, **kwargs)
            end
          end.inject(plugs: plugs, middleware_specifications: middlewares)
        end
      end
      # rubocop:enable Metrics/MethodLength

      def define_pipe_methods(mod)
        PIPE_METHODS.each do |method|
          mod.define_method(method) do |*args|
            @pipe.send(method, *args)
          end
        end
      end
    end
  end
end
