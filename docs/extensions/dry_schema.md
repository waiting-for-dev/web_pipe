# Dry Schema

Extension providing integration for a common
[`dry-schema`](https://dry-rb.org/gems/dry-schema/) workflow to validate
parameters.

A plug `WebPipe::Plugs::SanitizeParams` is added so that you can use it in your
pipe of operations. It takes as arguments a `dry-schema` schema and an handler.
On success, it makes available the output at `WebPipe::Conn#sanitized_params`.
On error, it calls the handler with the connection struct and the result.

This extension automatically loads `:params` extension, as it takes
`WebPipe::Conn#params` as the input for the validation schema.

Instead of providing an error handler as the second argument for the plug, it
can be configured under `:param_sanitization_handler` key. In this way, it can
be reused through composition by others applications.

```ruby
require 'db'
require 'dry/schema'
require 'web_pipe'
require 'web_pipe/plugs/config'

WebPipe.load_extensions(:dry_schema)

class MyApp
  include WebPipe
  
  Schema = Dry::Schema.Params do
    required(:name).filled(:string)
  end
  
  plug :config, WebPipe::Plugs::Config.(
    param_sanitization_handler: lamba do |conn, result|
      conn.
        set_status(500).
        set_response_body('Error with request parameters').
        halt
    end
  )
  
  plug :sanitize_params, WebPipe::Plugs::SanitizeParams.(
    Schema
  )
  
  plug(:this) do |conn|
    DB.persist(:entity, conn.sanitized_params)
  end
end
```
