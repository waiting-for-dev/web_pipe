# frozen_string_literal: true

module WebPipe
  module Plugs
    # Adds given pairs to {Conn#config}.
    #
    # @example
    #   class App
    #     include WebPipe
    #
    #     plug :config, WebPipe::Plugs::Config.(foo: :bar)
    #   end
    module Config
      def self.call(pairs)
        lambda do |conn|
          conn.new(
            config: conn.config.merge(pairs)
          )
        end
      end
    end
  end
end
