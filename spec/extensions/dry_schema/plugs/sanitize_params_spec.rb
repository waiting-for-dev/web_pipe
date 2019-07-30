require 'spec_helper'
require 'support/env'
require 'dry/schema'
require 'web_pipe/extensions/dry_schema/plugs/sanitize_params'
require 'web_pipe/conn_support/builder'

RSpec.describe WebPipe::Plugs::SanitizeParams do
  describe '.[]' do
    let(:schema) do
      schema = Dry::Schema.Params do
        required(:name)
      end
    end

    context 'operation on success' do
      it "sets sanitized_params bag's key" do
        env = default_env.merge(Rack::QUERY_STRING => 'name=Joe')
        conn = WebPipe::ConnSupport::Builder.(env)
        operation = described_class[schema]

        new_conn = operation.(conn)

        expect(new_conn.sanitized_params).to eq(name: 'Joe')
      end
    end

    context 'operation on failure' do
      it 'uses given handler if it is injected' do
        configured_handler = lambda do |conn, _result|
          conn.
            set_response_body('Something went wrong').
            set_status(500).
            taint
        end
        injected_handler = lambda do |conn, result|
          conn.
            set_response_body(result.errors.messages.inspect).
            set_status(500).
            taint
        end
        conn = WebPipe::ConnSupport::Builder.
                 (default_env).
                 put(:param_sanitization_handler, configured_handler)
        operation = described_class[schema, injected_handler]

        new_conn = operation.(conn)

        expect(new_conn.response_body[0]).to include('is missing')
      end

      it 'uses configured handler if none is injected' do
        configured_handler = lambda do |conn, _result|
          conn.
            set_response_body('Something went wrong').
            set_status(500).
            taint
        end
        conn = WebPipe::ConnSupport::Builder.
                 (default_env).
                 put(:param_sanitization_handler, configured_handler)
        operation = described_class[schema]

        new_conn = operation.(conn)

        expect(new_conn.response_body[0]).to eq('Something went wrong')
      end

      it 'uses default handler if none is injected nor configured' do
        conn = WebPipe::ConnSupport::Builder.(default_env)
        operation = described_class[schema]

        new_conn = operation.(conn)

        expect(new_conn.status).to be(500)
      end
    end
  end
end