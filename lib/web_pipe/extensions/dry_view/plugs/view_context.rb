require 'web_pipe/types'
require 'web_pipe/extensions/dry_view/dry_view'

module WebPipe
  module Plugs
    # Calls object with conn and puts the result into bag's `:view_context`.
    #
    # This is meant to contain a Proc which will be called with the same
    # {WebPipe::Conn} instance of the operation. It must return
    # request specific view context as a hash. Ultimately, this will
    # be provided to {Dry::View::Context#with} before passing the
    # result along to the view instance.
    #
    # @example
    #   class App
    #     include WebPipe
    #
    #     ViewContext = (conn) -> { { current_path: conn.full_path } }
    #
    #     plug :view_context, WebPipe::Plugs::ViewContext[ViewContext]
    #     plug :render
    #
    #     def render
    #       view(MyView.new)
    #     end
    #   end
    #
    # @see WebPipe::Conn#view
    module ViewContext
      def self.[](view_context_proc)
        Types.Interface(:call)[view_context_proc]
        lambda do |conn|
          conn.put(Conn::VIEW_CONTEXT_KEY, view_context_proc.(conn))
        end
      end
    end
  end
end
