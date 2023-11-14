# frozen_string_literal: true

module WebPipe
  # Composable rack application builder.
  #
  # An instance of this class helps build rack applications that can compose.
  # Besides the DSL, which only adds a convenience layer, this is the higher
  # abstraction on the library.
  #
  # Applications are built by plugging functions that take and return a
  # {WebPipe::Conn} instance. That's an immutable struct that contains all the
  # request information alongside methods to build the response. See {#plug} for
  # details.
  #
  # Middlewares can also be added to the resulting application thanks to {#use}.
  #
  # Be aware that instances of this class are immutable, so methods return new
  # objects every time.
  #
  # The instance itself is the final rack application.
  #
  # @example
  # # config.ru
  # app = WebPipe::Pipe.new
  #                    .use(:runtime, Rack::Runtime)
  #                    .plug(:content_type) do |conn|
  #                      conn.add_response_header('Content-Type', 'text/plain')
  #                    end
  #                    .plug(:render) do |conn|
  #                      conn.set_response_body('Hello, World!')
  #                    end
  #
  # run app
  class Pipe
    # Container that resolves nothing
    EMPTY_CONTAINER = {}.freeze

    # @!attribute [r] container
    #   Container from where resolve operations. See {#plug}.
    attr_reader :container

    # @!attribute [r] context
    #   Object from where resolve operations. See {#plug}.
    attr_reader :context

    # @api private
    EMPTY_PLUGS = [].freeze

    # @api private
    EMPTY_MIDDLEWARE_SPECIFICATIONS = [].freeze

    # @api private
    Container = Types.Interface(:[])

    # @api private
    attr_reader :plugs

    # @api private
    attr_reader :middleware_specifications

    # @param container [#to_h] Container from where resolve plug's operations
    # (see {#plug}).
    # @param context [Any] Object from where resolve plug's operations (see
    # {#plug})
    def initialize(
      container: EMPTY_CONTAINER,
      context: nil,
      plugs: EMPTY_PLUGS,
      middleware_specifications: EMPTY_MIDDLEWARE_SPECIFICATIONS
    )
      @plugs = plugs
      @middleware_specifications = middleware_specifications
      @container = Container[container]
      @context = context
    end

    # Names and adds a plug operation to the application.
    #
    # The operation can be provided in several ways:
    #
    # - Through the `spec` parameter as:
    #   - Anything responding to `#call` (like a {Proc}).
    #   - As a string or symbol key for something registered in {#container}.
    #   - Anything responding to `#to_proc` (like another {WebPipe::Pipe}
    #   instance or an instance of a class including {WebPipe}).
    #   - As `nil` (default), meaning that the operation is a method in
    #   {#context} matching the `name` parameter.
    # - Through a block, if the `spec` parameter is `nil`.
    #
    # @param name [Symbol]
    # @param spec [#call, #to_proc, String, Symbol, nil]
    # @yieldparam [WebPipe::Conn]
    #
    # @return [WebPipe::Pipe] A fresh new instance with the added plug.
    def plug(name, spec = nil, &block_spec)
      with(
        plugs: [
          *plugs,
          Plug.new(name: name, spec: spec || block_spec)
        ]
      )
    end

    # Names and adds a rack middleware to the final application.
    #
    # The middleware can be given in three forms:
    #
    # - As one or two arguments, the first one being a
    # rack middleware class, and optionally a second one with its initialization
    # options.
    # - As something responding to `#to_middlewares` with an array of
    # {WebPipe::RackSupport::Middleware} (like another {WebPipe::Pipe} instance
    # or a class including {WebPipe}), case in which all middlewares are used.
    #
    # @overload use(name, middleware_class)
    #   @param name [Symbol]
    #   @param middleware_class [Class]
    # @overload use(name, middleware_class, middleware_options)
    #   @param name [Symbol]
    #   @param middleware_class [Class]
    #   @param middleware_options [Any]
    # @overload use(name, to_middlewares)
    #   @param name [Symbol]
    #   @param middleware_class [#to_middlewares]
    #
    # @return [WebPipe::Pipe] A fresh new instance with the added middleware.
    def use(name, *spec)
      with(
        middleware_specifications: [
          *middleware_specifications,
          RackSupport::MiddlewareSpecification.new(name: name, spec: spec)
        ]
      )
    end

    # Shortcut for {#plug} and {#use} a pipe at once.
    #
    # @param name [#to_sym]
    # @param spec [#to_proc#to_middlewares]
    def compose(name, spec)
      use(name, spec)
        .plug(name, spec)
    end

    # Operations {#plug}ged to the app, mapped by their names.
    #
    # @return [Hash{Symbol => Proc}]
    def operations
      @operations ||= Hash[
        plugs.map { |plug| [plug.name, plug.(container, context)] }
      ]
    end

    # Middlewares {#use}d in the app, mapped by their names.
    #
    # Returns them wrapped within {WebPipe::RackSupport::Middleware} instances,
    # from where you can access their classes and options.
    #
    # @return [Hash{Symbol=>Array<WebPipe::RackSupport::Middleware>}]
    def middlewares
      @middlewares ||= Hash[
        middleware_specifications.map { |mw_spec| [mw_spec.name, mw_spec.()] }
      ]
    end

    # @api private
    def to_proc
      ConnSupport::Composition
        .new(operations.values)
        .method(:call)
    end

    # @api private
    def to_middlewares
      middlewares.values.flatten
    end

    # @api private
    def inject(plugs: {}, middleware_specifications: {})
      res_mw_specs = RackSupport::MiddlewareSpecification.inject(
        self.middleware_specifications, middleware_specifications
      )
      res_plugs = Plug.inject(
        self.plugs, plugs
      )
      with(
        plugs: res_plugs,
        middleware_specifications: res_mw_specs
      )
    end

    # @api private
    def call(env)
      rack_app.(env)
    end

    private

    def app
      App.new(operations.values).freeze
    end

    def rack_app
      RackSupport::AppWithMiddlewares.new(
        to_middlewares,
        app
      ).freeze
    end

    def with(plugs: nil, middleware_specifications: nil)
      self.class.new(
        container: container,
        context: context,
        middleware_specifications: middleware_specifications ||
                                     self.middleware_specifications,
        plugs: plugs || self.plugs
      )
    end
  end
end
