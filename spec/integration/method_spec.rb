require 'spec_helper'

RSpec.describe "Resolving from a method" do
  context "public method" do
    let(:pipe) do
      Class.new do
        include WebPipe

        plug :hello

        def hello(conn)
          conn.put_response_body('Hello, world!')
        end
      end.new
    end

    it 'can resolve operation from a public method' do
      expect(pipe.call({}).last).to eq(['Hello, world!'])
    end
  end

  context "private method" do
    let(:pipe) do
      Class.new do
        include WebPipe

        plug :hello

        private
        
        def hello(conn)
          conn.put_response_body('Hello, world!')
        end
      end.new
    end

    it 'can resolve operation from a private method' do
      expect(pipe.call({}).last).to eq(['Hello, world!'])
    end
  end
end