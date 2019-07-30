require 'spec_helper'
require 'support/env'
require 'web_pipe/conn_support/headers'

RSpec.describe WebPipe::ConnSupport::Headers do
  describe '.extract' do
    it 'returns hash with env HTTP_ pairs with prefix removed' do
      env = default_env.merge('HTTP_F' => 'BAR')

      headers = described_class.extract(env)

      expect(headers).to eq({ 'F' => 'BAR' })
    end

    it 'normalize keys' do
      env = default_env.merge('HTTP_FOO_BAR' => 'foobar')

      headers = described_class.extract(env)

      expect(headers).to eq({ 'Foo-Bar' => 'foobar' })
    end

    it 'includes content type CGI-like var' do
      env = default_env.merge('CONTENT_TYPE' => 'text/html')

      headers = described_class.extract(env)

      expect(headers['Content-Type']).to eq('text/html')
    end

    it 'includes content length CGI-like var' do
      env = default_env.merge('CONTENT_LENGTH' => '10')

      headers = described_class.extract(env)

      expect(headers['Content-Length']).to eq('10')
    end

    it 'defaults to empty hash' do
      headers = described_class.extract(default_env)

      expect(headers).to eq({})
    end
  end

  describe 'add' do
    it 'adds given pair to given headers' do
      headers = { 'Foo' => 'Bar' }

      new_headers = described_class.add(headers, 'Bar', 'Foo')

      expect(new_headers).to eq({ 'Foo' => 'Bar', 'Bar' => 'Foo' })
    end

    it 'normalize key' do
      headers = described_class.add({}, 'foo_foo', 'Bar')

      expect(headers).to eq({ 'Foo-Foo' => 'Bar' })
    end
  end

  describe 'delete' do
    it 'deletes response header with given key' do
      headers = { 'Foo' => 'Bar', 'Zoo' => 'Zar' }

      new_headers = described_class.delete(headers, 'Zoo')

      expect(new_headers).to eq({ 'Foo' => 'Bar' })
    end

    it 'accepts non normalized key' do
      headers = { 'Foo-Foo' => 'Bar' }

      new_headers = described_class.delete(headers, 'foo_foo')

      expect(new_headers).to eq({})
    end
  end

  describe '.normalize_key' do
    it 'does PascalCase on - and switches _ by -' do
      key = described_class.normalize_key('Foo-Bar')

      expect(key).to eq('Foo-Bar')
    end
  end
end