# frozen_string_literal: true

require 'spec_helper'
require 'support/conn'
require 'support/middlewares'

RSpec.describe 'Injecting middlewares' do
  let(:pipe) do
    Class.new do
      include WebPipe

      use :last_name, LastNameMiddleware, name: 'Doe'

      plug :hello

      private

      def hello(conn)
        last_name = conn.env['last_name']
        conn
          .set_response_body(
            "Hello Mr./Ms. #{last_name}"
          )
      end
    end.new(middlewares: { last_name: [LastNameMiddleware, name: 'Smith'] })
  end

  it 'can use middlewares' do
    expect(pipe.call(default_env).last[0]).to eq('Hello Mr./Ms. Smith')
  end
end
