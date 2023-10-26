# frozen_string_literal: true

require "web_pipe/types"
require "web_pipe/conn"
require "web_pipe"
require "web_pipe/extensions/hanami_view/hanami_view/context"
require "hanami/view"

# :nodoc:
module WebPipe
  # See the docs for the extension linked in the README.
  module HanamiView
    VIEW_CONTEXT_CLASS_KEY = :view_context_class
    private_constant :VIEW_CONTEXT_CLASS_KEY

    DEFAULT_VIEW_CONTEXT_CLASS = Class.new(WebPipe::HanamiView::Context)
    private_constant :DEFAULT_VIEW_CONTEXT_CLASS

    VIEW_CONTEXT_OPTIONS_KEY = :view_context_options
    private_constant :VIEW_CONTEXT_OPTIONS_KEY

    DEFAULT_VIEW_CONTEXT_OPTIONS = ->(_conn) { {} }

    # Sets string output of a view as response body.
    #
    # If the view is not a {Hanami::View} instance, it is resolved from
    # the configured container.
    #
    # `kwargs` is used as the input for the view (the arguments that
    # {Hanami::View#call} receives).
    #
    # @param view_spec [Hanami::View, Any]
    # @param kwargs [Hash] Arguments to pass along to `Hanami::View#call`
    #
    # @return WebPipe::Conn
    def view(view_spec, **kwargs)
      view_instance = view_instance(view_spec)

      set_response_body(
        view_instance.(**view_input(kwargs)).to_str
      )
    end

    private

    def view_instance(view_spec)
      return view_spec if view_spec.is_a?(Hanami::View)

      fetch_config(:container)[view_spec]
    end

    def view_input(kwargs)
      return kwargs if kwargs.key?(:context)

      context = fetch_config(
        VIEW_CONTEXT_CLASS_KEY, DEFAULT_VIEW_CONTEXT_CLASS
      ).new(
        **fetch_config(
          VIEW_CONTEXT_OPTIONS_KEY, DEFAULT_VIEW_CONTEXT_OPTIONS
        ).(self)
      )
      kwargs.merge(context: context)
    end
  end

  Conn.include(HanamiView)
end
