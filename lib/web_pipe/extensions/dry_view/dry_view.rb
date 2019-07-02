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
  # @see https://dry-rb.org/gems/dry-view/
  class Conn < Dry::Struct
    # Sets string output of a view as response body.
    #
    # @param view_instance [Dry::View]
    # @param kwargs [Hash] Arguments to pass along to `Dry::View#call`
    #
    # @return WebPipe::Conn
    def view(view_instance, **kwargs)
      set_response_body(
        view_instance.call(**kwargs).to_str
      )
    end
  end
end
