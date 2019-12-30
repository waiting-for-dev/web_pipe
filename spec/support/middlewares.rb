# frozen_string_literal: true

class FirstNameMiddleware
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    env['first_name'] = 'Joe'
    app.call(env)
  end
end

class LastNameMiddleware
  attr_reader :app
  attr_reader :name

  def initialize(app, opts)
    @app = app
    @name = opts[:name]
  end

  def call(env)
    env['last_name'] = name
    app.call(env)
  end
end
