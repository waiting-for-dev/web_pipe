require 'spec_helper'
require 'support/env'
require 'dry/view'
require 'dry/view/context'
require 'web_pipe/conn'
require 'web_pipe/conn_support/builder'

RSpec.describe WebPipe::Conn do
  before do
    WebPipe.load_extensions(:dry_view)
  end

  it "has a 'view_context' setting" do
    expect(described_class.settings).to include(:view_context)
  end

  describe '#view' do
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

    it 'can resolve view from the container' do
      view = Class.new(view_class) do
        config.template = 'template_without_input'
      end
      container = { 'view' => view.new }.freeze
      WebPipe::Conn.config.container = container
      conn = WebPipe::ConnSupport::Builder.call(DEFAULT_ENV)

      new_conn = conn.view('view')

      expect(new_conn.response_body).to eq(['Hello world'])
    end

    it "injects configured 'view_context' to the context" do
      view = Class.new(view_class) do
        config.template = 'template_with_input'
        config.default_context = Class.new(Dry::View::Context) do
          attr_reader :name

          def initialize(name: nil, **options)
            @name = name
            super
          end
        end.new
      end
      WebPipe::Conn.config.view_context = ->(conn) { { name: conn.fetch(:name) } }
      conn = WebPipe::ConnSupport::Builder.
               call(DEFAULT_ENV).
               put(:name, 'Joe')

      new_conn = conn.view(view.new)

      expect(new_conn.response_body).to eq(['Hello Joe'])
    end

    it "does not inject configured 'view_context' when context is explicit" do
      view = Class.new(view_class) do
        config.template = 'template_with_input'
      end
      context = Class.new(Dry::View::Context) do
        attr_reader :name

        def initialize(name: nil, **options)
          @name = name
          super
        end
      end.new(name: 'Alice')
      WebPipe::Conn.config.view_context = ->(_conn) { { name: 'Joe' } }
      conn = WebPipe::ConnSupport::Builder.call(DEFAULT_ENV)

      new_conn = conn.view(view.new, context: context)

      expect(new_conn.response_body).to eq(['Hello Alice'])
    end
  end
end