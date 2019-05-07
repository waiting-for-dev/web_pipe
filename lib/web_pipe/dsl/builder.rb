require 'dry/initializer'
require 'web_pipe/dsl/class_context'
require 'web_pipe/dsl/instance_methods'

module WebPipe
  module DSL
    # When an instance of it is included in a module, the module
    # extends a {ClassContext} instance and includes
    # {InstanceMethods}.
    #
    # @private
    class Builder < Module
      # Container with nothing registered.
      EMPTY_CONTAINER = {}.freeze
      
      # @!attribute [r] container
      # @return [Types::Container[]]


      include Dry::Initializer.define -> do
        option :container, type: Types::Container, default: proc { EMPTY_CONTAINER }
      end

      # @return [ClassContext]
      attr_reader :class_context

      def initialize(*args)
        super
        @class_context = ClassContext.new(container: container)
      end
      
      def included(klass)
        klass.extend(class_context)
        klass.include(InstanceMethods)
      end
    end
  end
end