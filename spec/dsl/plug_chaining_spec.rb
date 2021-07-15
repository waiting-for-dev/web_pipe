# frozen_string_literal: true

require 'spec_helper'
require 'support/conn'

RSpec.describe 'Chaining plugs' do
  let(:pipe) do
    Class.new do
      include WebPipe

      plug :one
      plug :two

      private

      def one(conn)
        conn.set_response_body('One')
      end

      def two(conn)
        conn.set_response_body(
          "#{conn.response_body[0]}Two"
        )
      end
    end.new
  end

  it 'chains successful plugs' do
    expect(pipe.call(default_env).last).to eq(['OneTwo'])
  end
end
