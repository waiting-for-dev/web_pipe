require 'web_pipe/types'

module WebPipe
  module Plugs
    # Sets a container into bag's `:container` key.
    #
    # Given container is check to respond to `#[]` method, which is
    # meant to be used to resolve dependencies.
    #
    # @example
    #   class App
    #     include WebPipe
    #
    #     Cont = { name: SomeDependency.new }.freeze
    #
    #     plug :container, WebPipe::Plugs::Container[Cont]
    #     plug :resolve
    #
    #     private
    #
    #     def resolve(conn)
    #       conn.put(:dependency, conn.fetch(:container)[:name])
    #     end
    #   end
    module Container
      def self.[](container)
        ->(conn) { conn.put(:container, Types::Container[container]) }
      end
    end
  end
end
