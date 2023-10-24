# Hanami View

This extension currently works with `hanami-view` v2.1.0.beta, which is not
still released but available on the gem repository.

This extension integrates with [hanami-view](https://github.com/hanami/view)
rendering system to set a hanami-view output as the response body.

`WebPipe::Conn#view` method is at the core of this extension. In its basic
behavior, you provide to it a view instance you want to render and any
exposures or options it may need:

```ruby
require 'web_pipe'
require 'hanami/view'
require 'my_context'

WebPipe.load_extensions(:hanami_view)

class SayHelloView < Hanami::View
  config.paths = [File.join(__dir__, '..', 'templates')]
  config.template = 'say_hello'

  expose :name
end
    
class MyApp
  include WebPipe

  plug :render
  
  private
  
  def render(conn)
    conn.view(SayHelloView.new, name: 'Joe')
  end
end
```
However, you can resolve a view from a container if you also use the
(`:container` extension)[container.md]:

```ruby
require 'hanami_view'
require 'my_container'
require 'web_pipe'
require 'web_pipe/plugs/config'

WebPipe.load_extensions(:hanami_view, :container)

class MyApp
 include WebPipe

 plug :config, WebPipe::Plugs::Config.(
   container: MyContainer
 )
 plug :render

 def render(conn)
   conn.view('views.say_hello', name: 'Joe')
 end
end
```

You can configure the view context class to use through the `:view_context_class` configuration option. The only requirement for it is to implement an initialize method accepting keyword arguments:

```ruby
require 'hanami/view'
require 'my_import'

class MyContext < Hanami::View::Context
  def initialize(current_path:)
    @current_path = current_path
  end
end
```

Then, you also need to configure a `:view_context_options` setting, which must be a lambda
accepting a `WebPipe::Conn` instance and returning a hash matching required arguments for
the view context class:

```ruby
require 'web_pipe'
require 'web_pipe/plugs/config'

WebPipe.load_extensions(:url)

class MyApp
  include WebPipe
  
  plug :config, WebPipe::Plugs::Config.(
    view_context_class: MyContext,
    view_context: ->(conn) { { current_path: conn.full_path} }
  )
  plug(:render) do |conn|
    conn.view(SayHelloView.new, name: 'Joe')
  end
end
```
