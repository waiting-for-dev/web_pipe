# Resolving operations

There are several ways you can specify how the operation is resolved.

## Instance method

Operations can be plugged through methods (whether public or private) in the
application class:

```ruby
class MyApp
  include WebPipe
  
  plug :html
  
  private
  
  def plug(conn)
    conn.add_response_header('Content-Type' => 'text/html')
  end
end
```

## Something responding to `#call`

Operations can also be plugged inline as anything that responds to `#call`,
like a `Proc` or a `lambda`:

```ruby
class MyApp
  include WebPipe
  
  plug(:html) { |conn| conn.add_response_header('Content-Type' => 'text/html') }
end
```

## Block

In the same way that `#call`, operations can also be plugged inline as blocks:

```ruby
class MyApp
  include WebPipe
  
  plug(:html) |conn|
    conn.add_response_header('Content-Type' => 'text/html')
  end
end
```

## Container

Operations can be resolved from a dependency injection container.

The container must be anything that responds to `#[]` (accepting symbols or
strings) in order to resolve the dependency. It is configured at the moment
`WebPipe` module is included:

```ruby
MyContainer = Hash[
  'plugs.html' => lambda do |conn|
    conn.add_response_header('Content-Type' => 'text/html')
   end
]

class MyApp
  include WebPipe.(container: MyContainer)
  
  plug :html, 'plugs.html'
end
```
