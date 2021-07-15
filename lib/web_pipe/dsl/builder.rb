# frozen_string_literal: true

require 'web_pipe/dsl/class_context'
require 'web_pipe/dsl/instance_context'
require 'web_pipe/pipe'

module WebPipe
  module DSL
    # @api private
    class Builder < Module
      attr_reader :class_context, :instance_context

      def initialize(container: Pipe::EMPTY_CONTAINER)
        @class_context = ClassContext.new
        @instance_context = InstanceContext.new(
          class_context: class_context,
          container: container
        )
        super()
      end

      def included(klass)
        klass.extend(class_context)
        klass.include(instance_context)
      end
    end
  end
end
