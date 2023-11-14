# frozen_string_literal: true

require "spec_helper"

RSpec.describe WebPipe::Plug do
  let(:container) do
    {
      callable: -> {},
      not_callable: nil
    }
  end
  let(:object) do
    Class.new do
      def public; end

      private

      def private; end
    end.new
  end

  describe "#with" do
    let(:name) { :name }
    let(:plug) { described_class.new(name: name, spec: nil) }

    let(:new_spec) { -> {} }
    let(:new_plug) { plug.with(new_spec) }

    it "returns new instance" do
      expect(new_plug).not_to be(plug)
    end

    it "keeps plug name" do
      expect(new_plug.name).to be(name)
    end

    it "replaces spec" do
      expect(new_plug.spec).to eq(new_spec)
    end
  end

  describe "#call" do
    let(:plug) { described_class.new(name: name, spec: spec) }

    context "when spec responds to #to_proc" do
      let(:name) { "name" }
      let(:spec) do
        Class.new do
          def to_proc
            -> { "hey" }
          end
        end.new
      end

      it "returns the result of calling it" do
        expect(plug.(container, object).()).to eq("hey")
      end
    end

    context "when spec responds to #to_proc but it's a symbol" do
      let(:name) { "name" }
      let(:spec) { :callable }

      it "resolves from the container" do
        expect(plug.(container, object)).to be(container[:callable])
      end
    end

    context "when spec is callable" do
      let(:name) { "name" }
      let(:spec) { -> {} }

      it "returns it" do
        expect(plug.(container, object)).to be(spec)
      end
    end

    context "when spec is nil" do
      let(:spec) { nil }

      context "when object has a public method with plug name" do
        let(:name) { "public" }

        it "returns a proc wrapping it" do
          expect(plug.(container, object)).to eq(object.method(:public))
        end
      end

      context "when object has a private method with plug name" do
        let(:name) { "private" }

        it "returns a proc wrapping it" do
          expect(plug.(container, object)).to eq(object.method(:private))
        end
      end
    end

    context "when is other thing" do
      let(:name) { "name" }

      context "when container resolves from it a callable object" do
        let(:spec) { :callable }

        it "returns it" do
          expect(plug.(container, object)).to be(container[:callable])
        end
      end

      context "when container resolves from it a not callable object" do
        let(:spec) { :not_callable }

        it "raises InvalidPlugError" do
          expect do
            plug.(container, object)
          end.to raise_error(WebPipe::Plug::InvalidPlugError)
        end
      end
    end
  end

  describe ".inject" do
    it "inject specs" do
      container = {
        "op1" => -> { "op1" },
        "op2" => -> { "op2" }
      }
      plugs = [
        described_class.new(name: :op1, spec: "op1"),
        described_class.new(name: :op2, spec: "op2")
      ]
      injected = { op2: -> { "injected" } }

      result = described_class.inject(
        plugs, injected
      )

      expect(result.map(&:name)).to eq(%i[op1 op2])
      expect(result.map { |plug| plug.(container, self) }.map(&:call)).to eq(%w[op1 injected])
    end
  end
end
