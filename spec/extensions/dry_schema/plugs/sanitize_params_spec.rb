# frozen_string_literal: true

require 'spec_helper'
require 'support/conn'
require 'dry/schema'
require 'web_pipe/extensions/dry_schema/plugs/sanitize_params'

RSpec.describe WebPipe::Plugs::SanitizeParams do
  describe '.call' do
    let(:schema) do
      Dry::Schema.Params do
        required(:name)
      end
    end

    context 'operation on success' do
      it "sets sanitized_params bag's key" do
        env = default_env.merge(Rack::QUERY_STRING => 'name=Joe')
        conn = build_conn(env)
        operation = described_class.call(schema)

        new_conn = operation.call(conn)

        expect(new_conn.sanitized_params).to eq(name: 'Joe')
      end
    end

    context 'operation on failure' do
      it 'uses given handler if it is injected' do
        configured_handler = lambda do |conn, _result|
          conn
            .set_response_body('Something went wrong')
            .set_status(500)
            .halt
        end
        injected_handler = lambda do |conn, result|
          conn
            .set_response_body(result.errors.messages.inspect)
            .set_status(500)
            .halt
        end
        conn = build_conn(default_env)
               .add_config(:param_sanitization_handler, configured_handler)
        operation = described_class.call(schema, injected_handler)

        new_conn = operation.call(conn)

        expect(new_conn.response_body[0]).to include('is missing')
      end

      it 'uses configured handler if none is injected' do
        configured_handler = lambda do |conn, _result|
          conn
            .set_response_body('Something went wrong')
            .set_status(500)
            .halt
        end
        conn = build_conn(default_env)
               .add_config(:param_sanitization_handler, configured_handler)
        operation = described_class.call(schema)

        new_conn = operation.call(conn)

        expect(new_conn).to be_halted
        expect(new_conn.response_body[0]).to eq('Something went wrong')
      end
    end
  end
end
