require 'spec_helper'

RSpec.describe "Composing" do
  context 'calling' do
    let(:pipe_1) do
      Class.new do
        include Dry::Request.Pipe()

        plug :one, with: -> (conn) { conn.put_response_body('One') }
      end
    end

    let(:pipe_2) do
      Class.new do
        include Dry::Request.Pipe()

        plug :two, with: -> (conn) { conn.put_response_body(conn.resp_body + 'Two') }
      end
    end

    it 'pipes can be composed' do
      expect((pipe_1 >> pipe_2).new.call({}).last).to eq(['OneTwo'])
    end
  end

  context 'container' do
    let(:pipe_1) do
      Class.new do
        self::Container = Hash["one" => ->(conn) { conn.put_response_body('One') }]

        include Dry::Request.Pipe(container: self::Container)

        plug :one, with: "one"
      end
    end

    let(:pipe_2) do
      Class.new do
        self::Container = Hash["one" => ->(conn) { conn.put_response_body('Two') }]

        include Dry::Request.Pipe(container: self::Container)
      end
    end

    it 'can specify another container' do
      expect((pipe_1.>>(pipe_2, container: pipe_2.container)).new.call({}).last).to eq(['Two'])
    end
  end
end