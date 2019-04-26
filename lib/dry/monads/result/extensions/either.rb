require "dry/core/extensions"

module Dry
  module Monads
    # This is currently a PR in dry-monads:
    #
    # https://github.com/dry-rb/dry-monads/pull/84
    class Result
      extend Dry::Core::Extensions

      register_extension(:either) do
        class Success
          # Returns result of applying first function to the internal value.
          #
          # @example
          #   Dry::Monads.Success(1).either(-> x { x + 1 }, -> x { x + 2 }) # => 2
          #
          # @param f [#call] Function to apply
          # @param g [#call] Ignored
          # @return [Any] Return value of `f`
          def either(f, _g)
            f.(success)
          end
        end

        class Failure
          # Returns result of applying second function to the internal value.
          #
          # @example
          #   Dry::Monads.Failure(1).either(-> x { x + 1 }, -> x { x + 2 }) # => 3
          #
          # @param f [#call] Ignored
          # @param g [#call] Function to call
          # @return [Any] Return value of `g`
          def either(_f, g)
            g.(failure)
          end
        end
      end
    end
  end
end