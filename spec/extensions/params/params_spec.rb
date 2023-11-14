# frozen_string_literal: true

require "spec_helper"
require "support/conn"

RSpec.describe WebPipe::Conn do
  before { WebPipe.load_extensions(:params) }

  describe "#params" do
    context "without transformations" do
      it "returns request params" do
        env = default_env.merge(
          Rack::QUERY_STRING => "foo=bar"
        )
        conn = build_conn(env)

        expect(conn.params).to eq("foo" => "bar")
      end
    end

    context "with transformations" do
      it "uses configured transformations" do
        env = default_env.merge(
          Rack::QUERY_STRING => "foo=bar&zoo=zoo"
        )
        conn = build_conn(env)
               .add_config(
                 :param_transformations, [:symbolize_keys, [:reject_keys, [:zoo]]]
               )

        expect(conn.params).to eq(foo: "bar")
      end

      it "uses injected transformation over configured" do
        env = default_env.merge(
          Rack::QUERY_STRING => "foo=bar"
        )
        conn = build_conn(env)
               .add_config(
                 :param_transformations, [:symbolize_keys]
               )

        expect(conn.params([:id])).to eq("foo" => "bar")
      end

      it "accepts transformations with no extra arguments" do
        env = default_env.merge(
          Rack::QUERY_STRING => "foo=bar"
        )
        conn = build_conn(env)
        transformations = [:symbolize_keys]

        expect(conn.params(transformations)).to eq(foo: "bar")
      end

      it "accepts transformations with extra arguments" do
        env = default_env.merge(
          Rack::QUERY_STRING => "foo=bar&zoo=zoo"
        )
        conn = build_conn(env)
        transformations = [[:reject_keys, ["zoo"]]]

        expect(conn.params(transformations)).to eq("foo" => "bar")
      end

      it "accepts transformations involving the conn instance" do
        WebPipe::Params::Transf.register(:from_bar, ->(value, conn) { value.merge(conn.env["bar"]) })
        env = default_env.merge(
          Rack::QUERY_STRING => "foo=bar",
          "bar" => { "bar" => "foo" }
        )
        conn = build_conn(env)
        transformations = [:from_bar]

        expect(conn.params(transformations)).to eq("foo" => "bar", "bar" => "foo")
      end

      it "accepts inline transformations" do
        conn = build_conn(default_env)
        transformations = [->(_params) { { boo: :foo } }]

        expect(conn.params(transformations)).to eq(boo: :foo)
      end
    end
  end
end
