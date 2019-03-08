require 'spec_helper'
require 'web_pipe/pipe/resolver'
require 'web_pipe/pipe/errors'

RSpec.describe WebPipe::Pipe::Resolver do
  let(:container) do
    {
      'from_container_callable' => -> {},
      'from_container_not_callable' => nil
    }
  end
  let(:instance) do
    Class.new do
      def public; end

      private

      def private; end
    end.new
  end
  let(:resolver) do
    described_class.new(container, instance)
  end

  describe '#call' do
    context 'when operation is callable' do
      it 'returns it' do
        operation = -> {}

        result = resolver.call(:name, operation)

        expect(result).to be(operation)
      end
    end

    context 'when operation is nil' do
      it 'returns proc for a public method of the instance' do
        result = resolver.call(:public, nil)

        expect(result).to eq(instance.method(:public))
      end

      it 'returns proc for a private method of the instance' do
        result = resolver.call(:private, nil)

        expect(result).to eq(instance.method(:private))
      end
    end

    context 'when is other thing' do
      it 'returns container item if it is callable' do
        result = resolver.call(:callable, "from_container_callable")

        expect(result).to eq(container["from_container_callable"])
      end

      it 'raises InvalidPlugError when container item is not callable' do
        expect {
          resolver.call(:not_callable, "from_container_not_callable")
        }.to raise_error(WebPipe::Pipe::InvalidPlugError)
      end
    end
  end
end