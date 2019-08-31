# frozen_string_literal: true

module WebPipe
  # Namespace for builders of operations on {WebPipe::Conn}.
  #
  # Plugs are just higher order functions: functions which return functions
  # (operations). For this reason, as a convention its interface is also
  # `#call`.
  module Plugs
  end
end
