# frozen_string_literal: true

require 'web_pipe/pipe'

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
        define_initialize(klass, class_context.ast, container)
        define_pipe_methods(klass)
      end

      private

      # rubocop:disable Metrics/MethodLength
      def define_initialize(klass, ast, container)
        klass.define_method(:initialize) do |plugs: {}, middlewares: {}|
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
        # rubocop:enable Metrics/MethodLength
      end

      def define_pipe_methods(klass)
        PIPE_METHODS.each do |method|
          klass.define_method(method) do |*args|
            @pipe.send(method, *args)
          end
        end
      end
    end
  end
end
