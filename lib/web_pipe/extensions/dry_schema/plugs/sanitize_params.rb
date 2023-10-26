# frozen_string_literal: true

require "web_pipe/types"
require "web_pipe/extensions/dry_schema/dry_schema"

module WebPipe
  module Plugs
    # Sanitize {Conn#params} with given `dry-schema` Schema.
    #
    # @see WebPipe::DrySchema
    module SanitizeParams
      # {Conn#config} key to store the handler.
      #
      # @return [Symbol]
      PARAM_SANITIZATION_HANDLER_KEY = :param_sanitization_handler

      # @param schema [Dry::Schema::Processor]
      # @param handler [ParamSanitizationHandler::Handler[]]
      #
      # @return [ConnSupport::Composition::Operation[], Types::Undefined]
      def self.call(schema, handler = Types::Undefined)
        lambda do |conn|
          result = schema.(conn.params)
          if result.success?
            conn.add_config(DrySchema::SANITIZED_PARAMS_KEY, result.output)
          else
            get_handler(conn, handler).(conn, result)
          end
        end
      end

      def self.get_handler(conn, handler)
        return handler unless handler == Types::Undefined

        conn.fetch_config(PARAM_SANITIZATION_HANDLER_KEY)
      end
      private_class_method :get_handler
    end
  end
end
