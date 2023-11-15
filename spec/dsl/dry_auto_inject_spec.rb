# frozen_string_literal: true

require "spec_helper"
require "support/conn"
require "dry/core"
require "dry/auto_inject"

RSpec.describe "Compatibility with dry-auto_inject" do
  context "when including web_pipe before dry-auto_inject" do
    let(:pipe_class) do
      Class.new do
        dependency = Class.new do
          def message
            "From dependency"
          end
        end

        container = Class.new do
          extend Dry::Core::Container::Mixin

          register :dependency do
            dependency.new
          end
        end

        import = Dry::AutoInject(container)

        include WebPipe
        include import[:dependency]

        plug :say_hello

        private

        def say_hello(conn)
          conn.set_response_body(dependency.message)
        end
      end
    end

    it "uses automatically injected dependencies" do
      expect(
        pipe_class.new.(default_env).last
      ).to eq(["From dependency"])
    end

    it "can inject a dependency" do
      dependency = Struct.new(:message).new("From injected")

      expect(
        pipe_class.new(dependency: dependency).(default_env).last
      ).to eq(["From injected"])
    end

    it "can inject a dependency and a plug" do
      dependency = Struct.new(:message).new("From injected")

      say_hello = ->(conn) { conn.set_response_body("#{dependency.message}, with plug injected") }

      expect(
        pipe_class.new(dependency: dependency, plugs: { say_hello: say_hello }).(default_env).last
      ).to eq(["From injected, with plug injected"])
    end
  end

  context "when including web_pipe after dry-auto_inject" do
    let(:pipe_class) do
      Class.new do
        dependency = Class.new do
          def message
            "From dependency"
          end
        end

        container = Class.new do
          extend Dry::Core::Container::Mixin

          register :dependency do
            dependency.new
          end
        end

        import = Dry::AutoInject(container)

        include import[:dependency]
        include WebPipe

        plug :say_hello

        private

        def say_hello(conn)
          conn.set_response_body(dependency.message)
        end
      end
    end

    it "uses automatically injected dependencies" do
      expect(
        pipe_class.new.(default_env).last
      ).to eq(["From dependency"])
    end

    it "can inject a dependency" do
      dependency = Struct.new(:message).new("From injected")

      expect(
        pipe_class.new(dependency: dependency).(default_env).last
      ).to eq(["From injected"])
    end

    it "can inject a dependency and a plug" do
      dependency = Struct.new(:message).new("From injected")

      say_hello = ->(conn) { conn.set_response_body("#{dependency.message}, with plug injected") }

      expect(
        pipe_class.new(dependency: dependency, plugs: { say_hello: say_hello }).(default_env).last
      ).to eq(["From injected, with plug injected"])
    end
  end
end
