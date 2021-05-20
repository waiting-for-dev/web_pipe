# Plugging operations

You can plug operations into your application with the DSL method `plug`. The
first argument it always takes is a symbol with the name you want
to give to the operation (which is needed to allow
[injection](plugging_operations/injecting_operations.md) at
initialization time).

```ruby
class MyApp
  include WebPipe
  
  plug :dummy_operation, ->(conn) { conn }
end
```

Remember, an operation is just a function (in ruby, anything responding to
`#call`) that takes a struct with connection information and returns another
instance of it. First operation in the stack receives a struct which has been
automatically created with the request data. From then on, any operation can
add to it response data.
