# Resolving operations

There are several ways you can specify how to resolve an operation.

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
