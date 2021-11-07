# frozen_string_literal: true

require 'web_pipe/types'
require 'web_pipe/conn'
require 'hanami/view'

# :nodoc:
module WebPipe
  # See the docs for the extension linked from the README.
  module DryView
    # Where to find in {#config} request's view context generator.
    VIEW_CONTEXT_KEY = :view_context

    # Default request's view context
    DEFAULT_VIEW_CONTEXT = ->(_conn) { Types::EMPTY_HASH }

    # Sets string output of a view as response body.
    #
    # If the view is not a {Hanami::View} instance, it is resolved from
    # the configured container.
    #
    # `kwargs` is used as the input for the view (the arguments that
    # {Hanami::View#call} receives). If they doesn't contain an explicit
    # `context:` key, it can be added through the injection of the
    # result of a lambda present in context's `:view_context`.(see
    # {Hanami::View::Context#with}).
    #
    # @param view_spec [Hanami::View, Any]
    # @param kwargs [Hash] Arguments to pass along to `Hanami::View#call`
    #
    # @return WebPipe::Conn
    def view(view_spec, **kwargs)
      view_instance = view_instance(view_spec)
      view_input = view_input(kwargs, view_instance)

      set_response_body(
        view_instance.call(
          **view_input
        ).to_str
      )
    end

    private

    def view_instance(view_spec)
      return view_spec if view_spec.is_a?(Hanami::View)

      fetch_config(:container)[view_spec]
    end

    def view_input(kwargs, view_instance)
      return kwargs if kwargs.key?(:context)

      context = view_instance
                .config
                .default_context
                .with(
                  **fetch_config(
                    VIEW_CONTEXT_KEY, DEFAULT_VIEW_CONTEXT
                  ).call(self)
                )
      kwargs.merge(context: context)
    end
  end

  Conn.include(DryView)
end
