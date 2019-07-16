require 'spec_helper'
require 'support/env'

RSpec.describe "Plug composition" do
  class One
    include WebPipe

    plug :one

    private

    def one(conn)
      conn.set_response_body('One')
    end
  end

  let(:pipe) do
    Class.new do
      include WebPipe

      plug :one, &One.new
      plug :two

      private

      def two(conn)
        conn.set_response_body(
          conn.response_body[0] + 'Two'
        )
      end
    end.new
  end

  it 'plugging a WebPipe composes its plug operations' do
    expect(pipe.call(DEFAULT_ENV).last).to eq(['OneTwo'])
  end
end