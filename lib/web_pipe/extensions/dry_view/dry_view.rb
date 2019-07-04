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
  # can be resolved from it. {WebPipe::Plugs::Container} can be used
  # to streamline this integration.
  #
  # @example
  #   class App
  #     include WebPipe
  #
  #     Container = { 'views.say_hello' => SayHelloView.new }.freeze
  #
  #     plug :container, with: WebPipe::Plugs::Container[Container]
  #     plug :render
  #
  #     def render(conn)
  #       conn.view('views.say_hello', name: 'Joe')
  #     end
  #  end
  #
  # In order to allow providing request context ({Dry::View::Context})
  # to the view, a setting `view_context` exists. Its value must be a
  # proc or lambda accepting the instance of {WebPipe::Conn} as
  # argument. This Proc must return a hash which will be injected to
  # the configured view instance context (see
  # {Dry::View::Context#with}) unless an explicit `context:` is given.
  #
  # @example
  #   WebPipe::Conn.config.view_context = lambda do |conn|
  #     {
  #       current_path: conn.full_path
  #     }
  #   end
  #
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
  #   # ...
  #     def render(conn)
  #       conn.view(SayHelloView.new, name: 'Joe') # `current_path`
  #       # will be available in the view scope
  #     end
  #   # ...
  #   
  # @see file:lib/web_pipe/extensions/container/container.rb
  # @see https://dry-rb.org/gems/dry-view/
  class Conn < Dry::Struct
    setting :view_context, ->(_conn) { {} }

    # Sets string output of a view as response body.
    #
    # If the view is not a {Dry::View} instance, it is resolved from
    # the configured container.
    #
    # `kwargs` is used as the input for the view (the arguments that
    # {Dry::View#call} receives). If they doesn't contain an explicit
    # `context:` key, it is added through injecting what is configured
    # as `view_context` to the view default context (see
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
                     WebPipe::Conn.config.view_context.(self)
                   )
      kwargs.merge(context: context)
    end
  end
end
