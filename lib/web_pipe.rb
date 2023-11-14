# frozen_string_literal: true

require "dry/core/extensions"
require "zeitwerk"

# Entry-point for the DSL layer.
#
# Including this module into your class adds to it a DSL layer which makes it
# convenient to interact with an instance of {WebPipe::Pipe} transparently. It
# means that the DSL is actually an optional layer, and you can achieve
# everything by using {WebPipe::Pipe} instances.
#
# Your class gets access to {WebPipe::DSL::ClassContext::DSL_METHODS} at the
# class level, while {WebPipe::DSL::InstanceContext::PIPE_METHODS} are available
# for every instance of it. Both groups of methods are delegating to
# {WebPipe::Pipe}, so you can look there for documentation.
#
# @example
#   class HelloWorld
#     include WebPipe
#
#     use :runtime, Rack::Runtime
#
#     plug :content_type do |conn|
#       conn.add_response_header('Content-Type', 'plain/text')
#     end
#
#     plug :render do |conn|
#       conn.set_response_body('Hello, World!')
#     end
#   end
#
# The instance of your class is itself the final rack application. When you
# initialize it, you have the chance to inject different plugs or middlewares
# from those defined at the class level.
#
# @example
#   HelloWorld.new(
#     middlewares: {
#       runtime: [Class.new do
#         def initialize(app)
#           @app = app
#         end
#
#         def call(env)
#           status, headers, body = @app.call(env)
#           [status, headers.merge('Injected' => '1'), body]
#         end
#       end]
#     },
#     plugs: {
#       render: ->(conn) { conn.set_response_body('Injected!') }
#     }
#   )
module WebPipe
  def self.loader
    Zeitwerk::Loader.for_gem.tap do |loader|
      loader.ignore(
        "#{__dir__}/web_pipe/conn_support/errors.rb",
        "#{__dir__}/web_pipe/extensions"
      )
      loader.inflector.inflect("dsl" => "DSL")
    end
  end
  loader.setup

  extend Dry::Core::Extensions

  # Called via {Module#include}, makes available web_pipe's DSL.
  #
  # Includes an instance of `Builder`. That means that `Builder#included` is
  # eventually called.
  def self.included(klass)
    klass.include(call)
  end

  # Chained to {Module#include} to make the DSL available and provide options.
  #
  # @param container [#[]] Container from where resolve operations. See
  # {WebPipe::Plug}.
  #
  # @example
  #   include WebPipe.call(container: Container)
  def self.call(**opts)
    DSL::Builder.new(**opts)
  end

  register_extension :container do
    require "web_pipe/extensions/container/container"
  end

  register_extension :cookies do
    require "web_pipe/extensions/cookies/cookies"
  end

  register_extension :dry_schema do
    require "web_pipe/extensions/dry_schema/dry_schema"
    require "web_pipe/extensions/dry_schema/plugs/sanitize_params"
  end

  register_extension :flash do
    require "web_pipe/extensions/flash/flash"
  end

  register_extension :hanami_view do
    require "web_pipe/extensions/hanami_view/hanami_view"
  end

  register_extension :not_found do
    require "web_pipe/extensions/not_found/not_found"
  end

  register_extension :params do
    require "web_pipe/extensions/params/params"
  end

  register_extension :rails do
    require "web_pipe/extensions/rails/rails"
  end

  register_extension :redirect do
    require "web_pipe/extensions/redirect/redirect"
  end

  register_extension :router_params do
    require "web_pipe/extensions/router_params/router_params"
  end

  register_extension :session do
    require "web_pipe/extensions/session/session"
  end

  register_extension :url do
    require "web_pipe/extensions/url/url"
  end
end
