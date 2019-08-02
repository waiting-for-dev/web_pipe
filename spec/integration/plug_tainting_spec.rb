require 'spec_helper'
require 'support/conn'

RSpec.describe "Plug tainting" do
  let(:pipe) do
    Class.new do
      include WebPipe

      plug :dirty
      plug :clean

      private

      def dirty(conn)
        conn.set_response_body('Dirty').taint
      end

      def clean(conn)
        conn.set_response_body('Clean')
      end
    end.new
  end

  it 'dirty plugs stops the pipe' do
    expect(pipe.call(default_env).last).to eq(['Dirty'])
  end
end