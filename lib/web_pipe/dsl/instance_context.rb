# frozen_string_literal: true

module WebPipe
  module DSL
    # @api private
    class InstanceContext < Module
      PIPE_METHODS = %i[
        call middlewares operations to_proc to_middlewares
      ].freeze

      attr_reader :class_context

      def initialize(class_context:)
        @class_context = class_context
        super()
      end

      def included(klass)
        klass.include(dynamic_module(class_context.ast))
      end

      private

      def dynamic_module(ast)
        Module.new.tap do |mod|
          define_initialize(mod, ast)
          define_pipe_methods(mod)
        end
      end

      # rubocop:disable Metrics/MethodLength
      def define_initialize(mod, ast)
        mod.define_method(:initialize) do |plugs: {}, middlewares: {}, **kwargs|
          super(**kwargs) # Compatibility with dry-auto_inject
          acc = Pipe.new(context: self)
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
