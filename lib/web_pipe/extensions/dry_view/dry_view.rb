require 'web_pipe/conn'
require 'dry/view'

module WebPipe
  load_extensions(:container)

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
  # This extension automaticaly loads `container` extension, allowing
  # the view to be resolved from the configured container:
  #
  # @example
  #   Container = { 'views.say_hello' => SayHelloView.new }.freeze
  #   WebPipe::Conn.config.container = Container
  #
  #   # ...
  #     def render(conn)
  #       conn.view('views.say_hello', name: 'Joe')
  #     end
  #   # ...
  #   
  # @see file:lib/web_pipe/extensions/container/container.rb
  # @see https://dry-rb.org/gems/dry-view/
  class Conn < Dry::Struct
    # Sets string output of a view as response body.
    #
    # If the view is not a {Dry::View} instance, it is resolved from
    # the configured container.
    #
    # @param view_spec [Dry::View, Any]
    # @param kwargs [Hash] Arguments to pass along to `Dry::View#call`
    #
    # @return WebPipe::Conn
    def view(view_spec, **kwargs)
      view_instance = if view_spec.is_a?(Dry::View)
                        view_spec
                      else
                        WebPipe::Conn.container[view_spec]
                      end
      set_response_body(
        view_instance.call(**kwargs).to_str
      )
    end
  end
end
