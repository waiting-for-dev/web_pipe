require 'dry/types'

module WebPipe
  module Pipe
    # Types used within {WebPipe::Pipe} namespace.
    module Types
      include Dry.Types()

      # Type constructor which validates value fulfills with expected
      # methods.
      #
      # @param methods [Array<Symbols>]
      #
      # @return [Object] on success
      # @raise Dry::Types::CoercionError when value does not respond
      # to all the methods.
      def self.Contract(*methods)
        Constructor(Nominal::Any) do |value|
          methods.reduce(value) do |value, method|
            if value.respond_to?(method)
              value
            else
              raise NoMethodError, "+#{value.inspect}+ does not respond to +#{method}+"
            end
          end
        end
      end

      # Anything which can resolve from a `#[]` method.
      Container = Contract(:[])
    end
  end
end