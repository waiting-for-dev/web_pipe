[![Gem Version](https://badge.fury.io/rb/web_pipe.svg)](https://badge.fury.io/rb/web_pipe)
[![Build Status](https://travis-ci.com/waiting-for-dev/web_pipe.svg?branch=master)](https://travis-ci.com/waiting-for-dev/web_pipe)

# WebPipe

`web_pipe` is a modular rack application builder through a pipe of
operations on an immutable struct.

In order to use in conjunction with [dry-rb](https://dry-rb.org/)
ecosystem, see also
[`dry-web-web_pipe`](https://github.com/waiting-for-dev/dry-web-web_pipe).

1. [Introduction](/docs/introduction.md)
1. [Design model](/docs/design_model.md)
1. [Building a rack application](/docs/building_a_rack_application.md)
1. [Plugging operations](/docs/plugging_operations.md)
   1. [Resolving operations](/docs/plugging_operations/resolving_operations.md)
   1. [Injecting operations](/docs/plugging_operations/injecting_operations.md)
   1. [Composing operations](/docs/plugging_operations/composing_operations.md)
1. [Using rack middlewares](/docs/using_rack_middlewares.md)
   1. [Injecting middlewares](/docs/using_rack_middlewares/injecting_middlewares.md)
   1. [Composing middlewares](/docs/using_rack_middlewares/composing_middlewares.md)
1. [Composing applications](/docs/composing_applications.md)
1. [Connection struct](/docs/connection_struct.md)
   1. [Sharing data downstream](/docs/connection_struct/sharing_data_downstream.md)
   1. [Halting the pipe](/docs/connection_struct/halting_the_pipe.md)
   1. [Configuring the connection struct](/docs/connection_struct/configuring_the_connection_struct.md)
1. [DSL free usage](/docs/dsl_free_usage.md)
1. [Plugs](/docs/plugs.md)
   1. [Config](/docs/plugs/config.md)
   1. [ContentType](/docs/plugs/content_type.md)
1. [Extensions](/docs/extensions.md)
   1. [Container](/docs/extensions/container.md)
   1. [Cookies](/docs/extensions/cookies.md)
   1. [Flash](/docs/extensions/flash.md)
   1. [Dry Schema](/docs/extensions/dry_schema.md)
   1. [Dry View](/docs/extensions/dry_view.md)
   1. [Params](/docs/extensions/params.md)
   1. [Redirect](/docs/extensions/redirect.md)
   1. [Router params](/docs/extensions/router_params.md)
   1. [Session](/docs/extensions/session.md)
   1. [URL](/docs/extensions/url.md)
1. Recipes
   1. [dry-rb integration](/docs/recipes/dry_rb_integration.md)
   1. [hanami-router integration](/docs/recipes/hanami_router_integration.md)
   1. [Using all RESTful methods](/docs/recipes/using_all_restful_methods.mb)

```ruby
# config.ru
require 'web_pipe'

WebPipe.load_extensions(:params)

class HelloApp
  include WebPipe
  
  AUTHORIZED_USERS = %w[Alice Joe]
  
  plug :html
  plug :authorize
  plug :greet
  
  private
  
  def html(conn)
    conn.add_response_header('Content-Type', 'text/html')
  end
  
  def authorize(conn)
    user = conn.params['user']
    if AUTHORIZED_USERS.include?(user)
      conn.add(:user, user)
    else
      conn.
        set_status(401).
        set_response_body('<h1>Not authorized</h1>').
        halt
    end
  end
  
  def greet(conn)
    conn.set_response_body("<h1>Hello #{conn.fetch(:user)}</h1>")
  end
end

run HelloApp.new
```

## Current status

`web_pipe` is in active development. The very basic features to build
a rack application are all available. However, very necessary
conveniences to build a production application, for example a session
mechanism, are still missing.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/waiting-for-dev/web_pipe.

## Release Policy

`web_pipe` follows the principles of [semantic versioning](http://semver.org/).
