# frozen_string_literal: true

module WebPipe
  module DSL
    # @api private
    class ClassContext < Module
      DSL_METHODS = %i[use plug compose].freeze

      attr_reader :ast

      def initialize
        @ast = []
        super
      end

      def extended(klass)
        define_dsl_methods(klass, ast)
      end

      private

      def define_dsl_methods(klass, ast)
        DSL_METHODS.each do |method|
          klass.define_singleton_method(method) do |*args, **kwargs, &block|
            ast << if block_given?
                     [method, args, kwargs, block]
                   else
                     [method, args, kwargs]
                   end
          end
        end
      end
    end
  end
end
