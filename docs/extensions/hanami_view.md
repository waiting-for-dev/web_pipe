# Hanami View

This extension currently works with `hanami-view` v2.0.0.alpha2, which is not
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
  config.default_context = MyContext

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

As in a standard call to `Hanami::View#call`, you can override the context
(`Hanami::View::Context`) to use through the `context:` option. However, it is still possible to leverage the configured default context while injecting specific data to it.

To work, you have to specify required dependencies (in this case,
request specific data) to your hanami-view's context. A very convenient way to do that is with [`dry-auto_inject`](https://dry-rb.org/gems/dry-auto_inject):

```ruby
require 'hanami/view/context'
require 'my_import'

class MyContext < Hanami::View::Context
 include MyImport::Import[:current_path]
 
 # Without `dry-auto_inject` you have to manually specify dependencies and
 # override the initializer:
 #
 # attr_reader :current_path
 # 
 # def initialize(current_path:, **options)
 #   @current_path = current_path
 #   super
 # end
end
```

Then, you have to configure a `:view_context` setting, which must be a lambda
accepting a `WebPipe::Conn` instance and returning a hash matching required
dependencies:

```ruby
require 'web_pipe'
require 'web_pipe/plugs/config'

WebPipe.load_extensions(:url)

class MyApp
  include WebPipe
  
  plug :config, WebPipe::Plugs::Config.(
    view_context: ->(conn) { { current_path: conn.full_path} }
  )
  plug(:render) do |conn|
    conn.view(SayHelloView.new, name: 'Joe')
    # `:current_path` will be provided to the context
  end
end
```
