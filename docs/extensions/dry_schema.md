# Dry Schema

Extension providing integration for every day
[`dry-schema`](https://dry-rb.org/gems/dry-schema/) workflow to validate
parameters.

A plug `WebPipe::Plugs::SanitizeParams` is added so that you can use it in your
pipe of operations. It takes as arguments a `dry-schema` schema and a handler.
On success, it makes output available at `WebPipe::Conn#sanitized_params`. On
error, it calls the given handler with the connection struct and validation
result.

This extension automatically loads [`:params` extension](params.md),
as it takes `WebPipe::Conn#params` as input for the validation schema.

Instead of providing an error handler as the second argument for the plug, you
can configure it under the `:param_sanitization_handler` key. In this way, it
can be reused through composition by other applications.

```ruby
require 'db'
require 'dry/schema'
require 'web_pipe'

WebPipe.load_extensions(:dry_schema)

class MyApp
  include WebPipe
  
  Schema = Dry::Schema.Params do
    required(:name).filled(:string)
  end
  
  plug :config, WebPipe::Plugs::Config.(
    param_sanitization_handler: lambda do |conn, result|
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
