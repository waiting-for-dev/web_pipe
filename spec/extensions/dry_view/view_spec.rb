require 'spec_helper'
require 'support/env'
require 'dry/view'
require 'web_pipe/conn'
require 'web_pipe/conn_support/builder'

RSpec.describe 'WebPipe::Conn#view' do
  before do
    WebPipe.load_extensions(:dry_view)
  end

  let(:view_class) do
    Class.new(Dry::View) do
      config.paths = [File.join(__dir__, 'fixtures')]
    end
  end

  it 'sets Rendered string serialization as response body' do
    view = Class.new(view_class) do
      config.template = 'template_without_input'
    end
    conn = WebPipe::ConnSupport::Builder.call(DEFAULT_ENV)

    new_conn = conn.view(view.new)

    expect(new_conn.response_body).to eq(['Hello world'])
  end

  it "passes kwargs along as view's call arguments" do
    view = Class.new(view_class) do
      config.template = 'template_with_input'

      expose :name
    end
    conn = WebPipe::ConnSupport::Builder.call(DEFAULT_ENV)

    new_conn = conn.view(view.new, name: 'Joe')

    expect(new_conn.response_body).to eq(['Hello Joe'])
  end

  it 'can resolve view from container' do
    view = Class.new(view_class) do
      config.template = 'template_without_input'
    end
    container = { 'view' => view.new }.freeze
    WebPipe::Conn.config.container = container
    conn = WebPipe::ConnSupport::Builder.call(DEFAULT_ENV)

    new_conn = conn.view('view')

    expect(new_conn.response_body).to eq(['Hello world'])
  end
end