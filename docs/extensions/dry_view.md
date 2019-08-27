# Dry View

This extensions integrates with
[dry-view](https://dry-rb.org/gems/dry-view/) rendering system to
set a dry-view output as response body.

`WebPipe::Conn#view` method is at the core of this extension. In its basic
behaviour, you provide to it the view instance you want to render and any
exposures or options it may need:

```ruby
require 'web_pipe'
require 'dry/view'
require 'my_context'

WebPipe.load_extensions(:dry_view)

class SayHelloView < Dry::View
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
    conn.view(SayHello.new, name: 'Joe')
  end
end
```

However, you can resolve the view from a container if you also use the `:container` extension:

```ruby
require 'dry_view'
require 'my_container'
require 'web_pipe'
require 'web_pipe/plugs/config'

WebPipe.load_extensions(:dry_view, :container)

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

As in a standard call to `Dry::View#call`, you can override the context
(`Dry::View::Context`) to use through the `context:` option. However, it is
still possible to leverage configured default context while being able to
inject request specific data to it.

For that to work, you have to specify required dependencies (in this case,
request specific data) to your dry-view's context. A very convenient way to do
that is with [`dry-auto_inject`](https://dry-rb.org/gems/dry-auto_inject):

```ruby
require 'dry/view/context'
require 'my_import'

class MyContext < Dry::View::Context
 include MyImport::Import[:current_path]
 
 # Without `dry-auto_inject` you have to manually specify the dependencies and
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
accepting the `WebPipe::Conn` instance and returning a hash matching required
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
