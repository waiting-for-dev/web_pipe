# frozen_string_literal: true

require "spec_helper"
require "support/conn"
require "hanami/view"
require "hanami/view/context"

RSpec.describe WebPipe::Conn do
  before do
    WebPipe.load_extensions(:hanami_view)
  end

  describe "#view" do
    let(:view_class) do
      Class.new(Hanami::View) do
        config.paths = [File.join(__dir__, "fixtures")]
      end
    end

    it "sets Rendered string serialization as response body" do
      view = Class.new(view_class) do
        config.template = "template_without_input"
      end
      conn = build_conn(default_env)

      new_conn = conn.view(view.new)

      expect(new_conn.response_body).to eq(["Hello world"])
    end

    it "passes kwargs along as view's call arguments" do
      view = Class.new(view_class) do
        config.template = "template_with_input"

        expose :name
      end
      conn = build_conn(default_env)

      new_conn = conn.view(view.new, name: "Joe")

      expect(new_conn.response_body).to eq(["Hello Joe"])
    end

    it "can resolve view from the container" do
      view = Class.new(view_class) do
        config.template = "template_without_input"
      end
      container = { "view" => view.new }.freeze
      conn = build_conn(default_env)
             .add_config(:container, container)

      new_conn = conn.view("view")

      expect(new_conn.response_body).to eq(["Hello world"])
    end

    it "initializes view_context class with the generated view_context_options hash" do
      view = Class.new(view_class) do
        config.template = "template_with_input"
      end
      context_class = Class.new(Hanami::View::Context) do
        attr_reader :name

        def initialize(name:)
          super
          @name = name
        end
      end
      conn = build_conn(default_env)
             .add(:name, "Joe")
             .add_config(:view_context_class, context_class)
             .add_config(:view_context_options, ->(c) { { name: c.fetch(:name) } })

      new_conn = conn.view(view.new)

      expect(new_conn.response_body).to eq(["Hello Joe"])
    end

    it "respects context given at render time if given" do
      view = Class.new(view_class) do
        config.template = "template_with_input"
      end
      context = Class.new(Hanami::View::Context) do
        def name
          "Alice"
        end
      end.new
      conn = build_conn(default_env)

      new_conn = conn.view(view.new, context: context)

      expect(new_conn.response_body).to eq(["Hello Alice"])
    end
  end
end
