# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased
### Added
- **BREAKING**: `container` is now an extension
  ([16](https://github.com/waiting-for-dev/web_pipe/pull/16)):
 
It adds a `Conn#container` method, while the plug while being the same than before it has been moved to `web_pipe/extensions/container/plugs/container`.

- No need to manually call `#to_proc` when composing plugs. This makes both of
  the following valid
  ([13](https://github.com/waiting-for-dev/web_pipe/pull/13)):

```ruby
plug :app, &App.new
plug :app, App.new
```

- Extension adding flash functionality to conn ([15](https://github.com/waiting-for-dev/web_pipe/pull/15)).

For this extension to work,
[`Rack::Flash`](https://github.com/treeder/rack-flash) and `Rack::Session`
middlewares must be used:

```ruby
require 'rack-flash'
require 'rack/session/cookie'

class App
  include WebPipe
  
  use :session, Rack::Session::Cookie, secret: 'secret'
  use :flash, Rack::Flash
  
  plug :put_in_flash, ->(conn) { conn.put_flash(:error, 'Error') }
  plug :put_in_flash_now, ->(conn) { conn.put_flash_now(:error_now, 'Error now') }
end
```

Usually you will expose `conn.flash` to your views.

### Fixed
- Fixed bug not allowing middlewares to modify responses initially set with
  default values ([14](https://github.com/waiting-for-dev/web_pipe/pull/14))

## [0.4.0] - 2019-07-17
### Added
- **BREAKING**: Middlewares have to be named when used
  ([11](https://github.com/waiting-for-dev/web_pipe/pull/11)):

```ruby
use :cookies, Rack::Session:Cookie, secret: 'my_secret', key: 'foo'
```

- **BREAKING**: Middlewares have to be initialized when composed
  ([11](https://github.com/waiting-for-dev/web_pipe/pull/11)):

```ruby
use :pipe, PipeWithMiddlewares.new
```

- **BREAKING**: The array of injected plugs is now scoped within a `plugs:`
  kwarg ([11](https://github.com/waiting-for-dev/web_pipe/pull/11)):

```ruby
App.new(plugs: { nothing: ->(conn) { conn } })
```

- Middlewares can be injected
  ([11](https://github.com/waiting-for-dev/web_pipe/pull/11)):

```ruby
App.new(middlewares: { cache: [MyMiddleware, my_options] })
```

- DSL helper method `compose` to add middlewares and plugs in order and in a
  single shot ([12](https://github.com/waiting-for-dev/web_pipe/pull/11)):

```ruby
class App
  include WebPipe.(container: Container)

  use :first, FirstMiddleware

  plug :first_plug, 'first_plug'
end

class AnotherApp
  include WebPipe.(container: Container)

  compose App
  # Equivalent to:
  # use App.new
  # plug &App.new

  use :second, SecondMiddleware

  plug :second_plug, 'second_plug'
end
```

## [0.3.0] - 2019-07-12
### Added
- **BREAKING**: When plugging with `plug:`, the operation is no longer
  specified through `with:`. Now it is just the second positional argument
  ([9](https://github.com/waiting-for-dev/web_pipe/pull/9)):

```ruby
plug :from_container, 'container'
plug :inline, ->(conn) { conn.set_response_body('Hello world') }
```
- It is possible to plug a block
  ([9](https://github.com/waiting-for-dev/web_pipe/pull/9)):
```ruby
  plug(:content_type) { |conn| conn.add_response_header('Content-Type', 'text/html') }
```

- WebPipe plug's can be composed. A WebPipe proc representation is the
  composition of all its operations, which is an operation itself
  ([9](https://github.com/waiting-for-dev/web_pipe/pull/9)):

```ruby
class HtmlApp
  include WebPipe

  plug :content_type
  plug :default_status

  private

  def content_type(conn)
    conn.add_response_header('Content-Type', 'text/html')
  end

  def default_status(conn)
    conn.set_status(404)
  end
end

class App
  include WebPipe

  plug :html, &HtmlApp.new
  plug :body

  private

  def body(conn)
     conn.set_response_body('Hello, world!')
  end
end
```

- WebPipe's middlewares can be composed into another WebPipe class, also
  through `:use` ([10](https://github.com/waiting-for-dev/web_pipe/pull/10)):

```ruby
class HtmlApp
  include WebPipe

  use Rack::Session::Cookie, key: 'key', secret: 'top_secret'
  use Rack::MethodOverride
end

class App
  include WebPipe

  use HtmlApp
end
```

## [0.2.0] - 2019-07-05
### Added
- dry-view integration
  ([#1](https://github.com/waiting-for-dev/web_pipe/pull/1),
  [#3](https://github.com/waiting-for-dev/web_pipe/pull/3),
  [#4](https://github.com/waiting-for-dev/web_pipe/pull/4),
  [#5](https://github.com/waiting-for-dev/web_pipe/pull/5) and
  [#6](https://github.com/waiting-for-dev/web_pipe/pull/6))
- Configuring a container in `WebPipe::Conn`
  ([#2](https://github.com/waiting-for-dev/web_pipe/pull/2) and
  [#5](https://github.com/waiting-for-dev/web_pipe/pull/5))
- Plug to set `Content-Type` response header
  ([#7](https://github.com/waiting-for-dev/web_pipe/pull/7))

### Fixed
- Fix key interpolation in `KeyNotFoundInBagError`
  ([#8](https://github.com/waiting-for-dev/web_pipe/pull/8))

## [0.1.0] - 2019-05-07
### Added
- Initial release.
