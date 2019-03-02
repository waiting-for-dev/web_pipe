require 'web_pipe/class_context'
require 'web_pipe/instance_methods'

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
  end
end