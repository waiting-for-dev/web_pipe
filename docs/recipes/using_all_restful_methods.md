# Using all RESTful methods

As you probably know, most browsers don't support some RESTful
methods like `PATCH` or `PUT`. [Rack's `MethodOverride`
middleware](https://github.com/rack/rack/blob/master/lib/rack/method_override.rb)
provides a workaround for this limitation, allowing to override
request method in rack's env if a magical `_method` parameter or
`HTTP_METHOD_OVERRIDE` request header is found.

You have to be aware that if you use this middleware within a
`web_pipe` application (through [`use` DSL
method](../using_rack_middlewares.md)), it will have no effect.
When your `web_pipe` application takes control of the request, it
has already gone through the router, which is the one that should
read the request method set by rack.

The solution for this is straightforward. Just use `MethodOverride` middleware
before your router does its work. For example, in `config.ru`:

```ruby
# config.ru

use Rack::MethodOverride

# Load your router and map to web_pipe applications
```
