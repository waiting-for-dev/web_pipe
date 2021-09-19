# frozen_string_literal: true

#:nodoc:
module WebPipe
  # Generates a not-found response
  #
  # This extension helps to build a not-found response in a single method
  # invocation. The {#not_found} method will:
  #
  # - Set 404 as response status.
  # - Set 'Not found' as the response body, or instead run a step configured in
  # a `:not_found_body_step` config key.
  # - Halt the connection struct.
  #
  # @example
  #   require 'web_pipe'
  #   require 'web_pipe/plugs/config'
  #
  #   WebPipe.load_extensions(:params, :not_found)
  #
  #   class ShowItem
  #     include 'web_pipe'
  #
  #     plug :config, WebPipe::Plugs::Config.(
  #       not_found_body_step: ->(conn) { conn.set_response_body('Nothing') }
  #     )
  #
  #     plug :fetch_item do |conn|
  #       conn.add(:item, Item[params['id']])
  #     end
  #
  #     plug :check_item do |conn|
  #       if conn.fetch(:item)
  #         conn
  #       else
  #         conn.not_found
  #       end
  #     end
  #
  #     plug :render do |conn|
  #       conn.set_response_body(conn.fetch(:item).name)
  #     end
  #   end
  module NotFound
    # @api private
    RESPONSE_BODY_STEP_CONFIG_KEY = :not_found_body_step

    # Generates the not-found response
    #
    # @return [WebPipe::Conn::Halted]
    # @see NotFound
    def not_found
      set_status(404)
        .then do |conn|
          response_body_step = conn.fetch_config(RESPONSE_BODY_STEP_CONFIG_KEY,
                                                 ->(c) { c.set_response_body('Not found') })

          response_body_step.call(conn)
        end.halt
    end

    Conn.include(NotFound)
  end
end
