# Configuring the connection struct

[Extensions](../extensions.md) add extra behaviour to the connection struct.
Sometimes they need some user provided value to work properly or they may allow
some tweak depending on user needs.

For this reason, you can add configuration data to a `WebPipe::Conn` instance
so that extensions can fetch it. This shared place where extensions look for
what they need is `#config` attribute, which is very similar to `#bag` except
for its more private intention.

In order to interact with `#config`, you can use the method `#add_config(key,
value)` or [`Config` plug](../plugs/config.md).

```ruby
class MyApp
  include WebPipe
  
  plug(:config) do |conn|
    conn.add_config(
      foo: :bar
    )
  end
end
```
