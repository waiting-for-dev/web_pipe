# frozen_string_literal: true

require 'web_pipe/conn'

# :nodoc:
module WebPipe
  # See the docs for the extension linked from the README.
  module Rails
    def render(*args)
      set_response_body(
        rails_controller.renderer.render(*args)
      )
    end

    # @see https://devdocs.io/rails~6.0/actioncontroller/helpers
    def helpers
      rails_controller.helpers
    end

    # @see https://api.rubyonrails.org/v6.0.1/classes/ActionView/Helpers/UrlHelper.html
    def url_helpers
      ::Rails.application.routes.url_helpers
    end

    private

    def rails_controller
      config.fetch(:rails_controller, ActionController::Base)
    end
  end

  Conn.include(Rails)
end
