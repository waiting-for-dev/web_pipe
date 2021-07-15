# frozen_string_literal: true

require 'spec_helper'
require 'support/conn'
require 'support/middlewares'
require 'web_pipe/pipe'
require 'web_pipe/plugs'
require 'web_pipe/rack_support/middleware'
require 'web_pipe/rack_support/middleware_specification'

RSpec.describe WebPipe::Pipe do
  describe '#plug' do
    context 'when no other plugs are present' do
      it 'initializes the queue with the given plug' do
        pipe = described_class.new.plug(:one, 'key')

        expect(pipe.plugs).to eq(
          [WebPipe::Plug.new(name: :one, spec: 'key')]
        )
      end
    end

    context 'when other plugs are present' do
      it 'adds the new plug at the end of the queue' do
        pipe = described_class
               .new
               .plug(:one)
               .plug(:two, 'key')

        expect(pipe.plugs).to eq(
          [
            WebPipe::Plug.new(name: :one, spec: nil),
            WebPipe::Plug.new(name: :two, spec: 'key')
          ]
        )
      end
    end

    it 'returns a new instance' do
      pipe1 = described_class.new

      pipe2 = pipe1.plug(:one)

      expect(pipe2).to be_an_instance_of(described_class)
      expect(pipe2).not_to eq(pipe1)
    end
  end

  describe '#use' do
    context 'when no other middleware specifications are present' do
      it 'initializes the queue with the given specification' do
        pipe = described_class.new.use(:one, FirstNameMiddleware)

        expect(pipe.middleware_specifications).to eq(
          [WebPipe::RackSupport::MiddlewareSpecification.new(name: :one, spec: [FirstNameMiddleware])]
        )
      end
    end

    context 'when other middleware specifications are present' do
      it 'adds the new specification at the end of the queue' do
        pipe = described_class
               .new
               .use(:one, FirstNameMiddleware)
               .use(:two, LastNameMiddleware, name: 'Alice')

        expect(pipe.middleware_specifications).to eq(
          [
            WebPipe::RackSupport::MiddlewareSpecification.new(name: :one, spec: [FirstNameMiddleware]),
            WebPipe::RackSupport::MiddlewareSpecification.new(name: :two,
                                                              spec: [
                                                                LastNameMiddleware, { name: 'Alice' }
                                                              ])
          ]
        )
      end
    end

    it 'returns a new instance' do
      pipe1 = described_class.new

      pipe2 = pipe1.use(:one, Object)

      expect(pipe2).to be_an_instance_of(described_class)
      expect(pipe2).not_to eq(pipe1)
    end
  end

  describe '#compose' do
    let(:base) { described_class.new }

    it 'adds the plug to the queue' do
      pipe = described_class.new.compose(:one, base)

      expect(pipe.plugs).to eq(
        [WebPipe::Plug.new(name: :one, spec: base)]
      )
    end

    it 'adds the middleware specification to the queue' do
      pipe = described_class.new.compose(:one, base)

      expect(pipe.middleware_specifications).to eq(
        [WebPipe::RackSupport::MiddlewareSpecification.new(name: :one, spec: [base])]
      )
    end

    it 'returns a new instance' do
      pipe1 = described_class.new

      pipe2 = pipe1.compose(:one, base)

      expect(pipe2).to be_an_instance_of(described_class)
      expect(pipe2).not_to eq(pipe1)
    end
  end

  describe '#operations' do
    it 'maps plug names with resolved operations' do
      pipe = described_class.new
                            .plug(:one, proc { |_conn| 'one' })
                            .plug(:two, proc { |_conn| 'two' })

      operations = pipe.operations

      expect(operations.map { |name, op| [name, op.call] }).to eq([[:one, 'one'], [:two, 'two']])
    end
  end

  describe '#middlewares' do
    it 'maps middleware specifications names with resolved middlewares' do
      pipe = described_class.new
                            .use(:one, FirstNameMiddleware)
                            .use(:two, LastNameMiddleware, name: 'Alice')

      middlewares = pipe.middlewares

      expect(middlewares).to eq(
        {
          one: [WebPipe::RackSupport::Middleware.new(middleware: FirstNameMiddleware, options: [])],
          two: [WebPipe::RackSupport::Middleware.new(middleware: LastNameMiddleware, options: [{ name: 'Alice' }])]
        }
      )
    end
  end

  describe '#to_proc' do
    it 'returns the kleisli composition of all the plugged operations' do
      pipe = described_class.new
                            .plug(:one, ->(conn) { conn.set_response_body('one') })
                            .plug(:two, ->(conn) { conn.halt })
                            .plug(:three, ->(conn) { conn.set_response_body('three') })

      to_proc = pipe.to_proc

      expect(to_proc.call(build_conn).response_body).to eq(['one'])
    end
  end

  describe '#to_middlewares' do
    it 'returns all used middlewares' do
      pipe = described_class.new
                            .use(:one, FirstNameMiddleware)
                            .use(:two, LastNameMiddleware, name: 'Alice')

      to_middlewares = pipe.to_middlewares

      expect(to_middlewares).to eq(
        [
          WebPipe::RackSupport::Middleware.new(middleware: FirstNameMiddleware, options: []),
          WebPipe::RackSupport::Middleware.new(middleware: LastNameMiddleware, options: [{ name: 'Alice' }])
        ]
      )
    end
  end

  describe '#inject' do
    it 'substitutes matching plug operation' do
      pipe = described_class.new
                            .plug(:one, 'one')
                            .plug(:two, 'two')
                            .inject(plugs: { one: 'injected' })

      expect(pipe.plugs).to eq(
        [
          WebPipe::Plug.new(name: :one, spec: 'injected'),
          WebPipe::Plug.new(name: :two, spec: 'two')
        ]
      )
    end

    it 'substitutes matching middleware specifications' do
      pipe = described_class.new
                            .use(:one, FirstNameMiddleware)
                            .use(:two, LastNameMiddleware, name: 'Alice')
                            .inject(middleware_specifications: { two: [FirstNameMiddleware] })

      expect(pipe.middleware_specifications).to eq(
        [
          WebPipe::RackSupport::MiddlewareSpecification.new(name: :one, spec: [FirstNameMiddleware]),
          WebPipe::RackSupport::MiddlewareSpecification.new(name: :two, spec: [FirstNameMiddleware])
        ]
      )
    end
  end

  describe '#call' do
    it 'behaves like a rack application' do
      pipe = described_class.new
                            .plug :hello do |conn|
        conn
          .set_response_body('Hello, world!')
          .set_status(200)
      end

      expect(pipe.call(default_env)).to eq([200, {}, ['Hello, world!']])
    end

    it 'can resolve plug operation from a callable' do
      one = ->(conn) { conn.set_response_body('One') }
      pipe = described_class.new
                            .plug(:one, one)

      response = pipe.call(default_env)

      expect(response.last).to eq(['One'])
    end

    it 'can resolve plug operation from a block' do
      pipe = described_class.new
                            .plug :one do |conn|
                              conn.set_response_body('One')
                            end

      response = pipe.call(default_env)

      expect(response.last).to eq(['One'])
    end

    it 'can resolve plug operation from the context object' do
      context = Class.new do
        def self.one(conn)
          conn.set_response_body(['One'])
        end
      end
      pipe = described_class.new(context: context)
                            .plug(:one)

      response = pipe.call(default_env)

      expect(response.last).to eq(['One'])
    end

    it 'can resolve plug operation from the container' do
      container = {
        one_key: ->(conn) { conn.set_response_body(['One']) }
      }
      pipe = described_class.new(container: container)
                            .plug(:one, :one_key)

      response = pipe.call(default_env)

      expect(response.last).to eq(['One'])
    end

    it 'can resolve plug operation from something responding to to_proc' do
      one = Class.new do
        def self.to_proc
          ->(conn) { conn.set_response_body('One') }
        end
      end
      pipe = described_class.new
                            .plug(:one, one)

      response = pipe.call(default_env)

      expect(response.last).to eq(['One'])
    end

    it 'can resolve plug operation from another pipe' do
      one = ->(conn) { conn.set_response_body('One') }
      two = ->(conn) { conn.set_response_body("#{conn.response_body[0]}Two") }
      three = ->(conn) { conn.set_response_body("#{conn.response_body[0]}Three") }
      pipe1 = described_class.new
                             .plug(:two, two)
                             .plug(:three, three)
      pipe2 = described_class.new
                             .plug(:one, one)
                             .plug(:pipe1, pipe1)

      response = pipe2.call(default_env)

      expect(response.last).to eq(['OneTwoThree'])
    end

    it 'chains plug operations' do
      one = ->(conn) { conn.set_response_body('One') }
      two = ->(conn) { conn.set_response_body("#{conn.response_body[0]}Two") }
      pipe = described_class.new
                            .plug(:one, one)
                            .plug(:two, two)

      response = pipe.call(default_env)

      expect(response.last).to eq(['OneTwo'])
    end

    it 'stops chain of plugs when halting' do
      one = ->(conn) { conn.set_response_body('One') }
      two = ->(conn) { conn.halt }
      three = ->(conn) { conn.set_response_body('Three') }
      pipe = described_class.new
                            .plug(:one, one)
                            .plug(:two, two)
                            .plug(:three, three)

      response = pipe.call(default_env)

      expect(response.last).to eq(['One'])
    end

    it 'keeps stoping the chain if halted when plugging another pipe' do
      one = ->(conn) { conn.set_response_body('One') }
      two = ->(conn) { conn.halt }
      three = ->(conn) { conn.set_response_body('Three') }
      pipe1 = described_class.new
                             .plug(:two, two)
                             .plug(:three, three)
      pipe2 = described_class.new
                             .plug(:one, one)
                             .plug(:pipe1, pipe1)

      response = pipe2.call(default_env)

      expect(response.last).to eq(['One'])
    end

    it 'can use a middleware' do
      hello = lambda do |conn|
        first_name = conn.env['first_name']
        last_name = conn.env['last_name']
        conn
          .set_response_body(
            "Hello #{first_name} #{last_name}"
          )
      end
      pipe = described_class.new
                            .use(:first_name, FirstNameMiddleware)
                            .use(:last_name, LastNameMiddleware, name: 'Doe')
                            .plug(:hello, hello)

      response = pipe.call(default_env)

      expect(response.last).to eq(['Hello Joe Doe'])
    end

    it 'can use middlewares from something responding to #to_middlewares' do
      middlewares = Class.new do
        def self.to_middlewares
          [
            WebPipe::RackSupport::Middleware.new(middleware: FirstNameMiddleware, options: []),
            WebPipe::RackSupport::Middleware.new(middleware: LastNameMiddleware, options: [{ name: 'Doe' }])
          ]
        end
      end
      hello = lambda do |conn|
        first_name = conn.env['first_name']
        last_name = conn.env['last_name']
        conn
          .set_response_body(
            "Hello #{first_name} #{last_name}"
          )
      end
      pipe = described_class.new
                            .use(:middlewaers, middlewares)
                            .plug(:hello, hello)

      response = pipe.call(default_env)

      expect(response.last).to eq(['Hello Joe Doe'])
    end

    it 'can use middlewares from another pipe' do
      pipe1 = described_class.new
                             .use(:first_name, FirstNameMiddleware)
                             .use(:last_name, LastNameMiddleware, name: 'Doe')
      hello = lambda do |conn|
        first_name = conn.env['first_name']
        last_name = conn.env['last_name']
        conn
          .set_response_body(
            "Hello #{first_name} #{last_name}"
          )
      end
      pipe = described_class.new
                            .use(:pipe1, pipe1)
                            .plug(:hello, hello)

      response = pipe.call(default_env)

      expect(response.last).to eq(['Hello Joe Doe'])
    end
  end
end
