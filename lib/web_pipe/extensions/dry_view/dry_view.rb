require 'web_pipe/types'
require 'web_pipe/conn'
require 'dry/view'

module WebPipe
  # Integration with `dry-view` rendering system.
  #
  # This extensions adds a {#view} method to {WebPipe::Conn} which
  # sets the string output of a `dry-view` view as response body.
  #
  # @example
  #   WebPipe.load_extensions(:dry_view)
  #
  #   class SayHelloView < Dry::View
  #     config.paths = [File.join(__dir__, '..', 'templates')]
  #     config.template = 'say_hello'
  #
  #     expose :name
  #   end
  #     
  #   class App
  #     include WebPipe
  #
  #     plug :render
  #
  #     def render(conn)
  #       conn.view(SayHello.new, name: 'Joe')
  #     end
  #   end
  #
  # If {WebPipe::Conn#bag} has a `:container` key, the view instance
  # can be resolved from it. {WebPipe::Container} extension can be
  # used to streamline this integration.
  #
  # @example
  #   WebPipe.load_extensions(:dry_view, :container)
  #
  #   class App
  #     include WebPipe
  #
  #     Container = { 'views.say_hello' => SayHelloView.new }.freeze
  #
  #     plug :container, WebPipe::Plugs::Container[Container]
  #     plug :render
  #
  #     def render(conn)
  #       conn.view('views.say_hello', name: 'Joe')
  #     end
  #  end
  #
  # Context ({Dry::View::Context}) for the view can be set explicetly
  # through the `context:` argument, as in a standard call to
  # {Dry::View#call}. However, it is possible to leverage configured
  # default context while still being able to inject request specific
  # context. For that to work, a key `:view_context` should be present
  # in {WebPipe::Conn#bag}. It must be equal to a hash which will be
  # passed to {Dry::View::Context#with} to create the final context:
  #
  # @example
  #   class MyContext < Dry::View::Context
  #     attr_reader :current_path
  #
  #     def initialize(current_path: nil, **options)
  #       @current_path = current_path
  #       super
  #     end
  #   end
  #
  #   class SayHelloView < Dry::View
  #     config.paths = [File.join(__dir__, '..', 'templates')]
  #     config.template = 'say_hello'
  #     config.default_context = MyContext.new
  #
  #     expose :name
  #   end
  #
  #   class App
  #     include WebPipe
  #
  #     plug :set_view_context
  #     plug :render
  #
  #     def set_view_context(conn)
  #       conn.put(:view_context, { current_path: conn.full_path })
  #     end
  #
  #     def render(conn)
  #       conn.view(SayHelloView.new, name: 'Joe') # `current_path`
  #       # will be available in the view scope
  #     end
  #   end
  #
  # It can be streamline using {WebPipe::Plugs::ViewContext} plug,
  # which accepts a callable object which should return the request
  # context from given {WebPipe::Conn}:
  #
  # @example
  #  # ...
  #    plug :set_view_context, WebPipe::Plugs::ViewContext[
  #                              ->(conn) { { current_path: conn.full_path } }
  #                            ]
  #  # ...
  #   
  # @see https://dry-rb.org/gems/dry-view/
  # @see WebPipe::Container
  module DryView
    # Where to find in {#bag} request's view context
    VIEW_CONTEXT_KEY = :view_context

    # Default request's view context
    DEFAULT_VIEW_CONTEXT = Types::EMPTY_HASH

    # Sets string output of a view as response body.
    #
    # If the view is not a {Dry::View} instance, it is resolved from
    # the configured container.
    #
    # `kwargs` is used as the input for the view (the arguments that
    # {Dry::View#call} receives). If they doesn't contain an explicit
    # `context:` key, it can be added through the injection injection
    # of what is present in bag's `:view_context`.(see
    # {Dry::View::Context#with}).
    #
    # @param view_spec [Dry::View, Any]
    # @param kwargs [Hash] Arguments to pass along to `Dry::View#call`
    #
    # @return WebPipe::Conn
    def view(view_spec, **kwargs)
      view_instance = view_instance(view_spec)
      view_input = view_input(kwargs, view_instance)
      
      set_response_body(
        view_instance.call(
          view_input
        ).to_str
      )
    end

    private

    def view_instance(view_spec)
      return view_spec if view_spec.is_a?(Dry::View)

      fetch(:container)[view_spec]
    end

    def view_input(kwargs, view_instance)
      return kwargs if kwargs.key?(:context)

      context =  view_instance.
                   config.
                   default_context.
                   with(
                     fetch(VIEW_CONTEXT_KEY, DEFAULT_VIEW_CONTEXT)
                   )
      kwargs.merge(context: context)
    end
  end

  Conn.include(DryView)
end
