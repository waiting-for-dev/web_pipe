# Resolving operations

There are several ways you can specify how an operation is resolved.

## Instance method

Operations can be plugged as methods (both public and private) in the
application class:

```ruby
class MyApp
  include WebPipe
  
  plug :html
  
  private
  
  def html(conn)
    conn.add_response_header('Content-Type' => 'text/html')
  end
end
```

## `#call`

Operations can be plugged inline as anything responding to `#call`, like a
`Proc` or a `lambda`:

```ruby
class MyApp
  include WebPipe
  
  plug :html, ->(conn) { conn.add_response_header('Content-Type' => 'text/html') }
end
```

## Block

In the same way that `#call`, operations can also be plugged inline as blocks:

```ruby
class MyApp
  include WebPipe
  
  plug :html do |conn|
    conn.add_response_header('Content-Type' => 'text/html')
  end
end
```

## Container

Operations can be resolved from a dependency injection container.

A container is anything that responds to `#[]` (accepting `Symbol` or `String`
as argument) in order to resolve a dependency. It can be configured at the
moment `WebPipe` module is included:

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
