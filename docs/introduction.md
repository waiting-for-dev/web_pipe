# Introduction

`web_pipe` is a rack application builder.

It means that with it and a rack router (like
[`hanami-router`](https://github.com/hanami/router),
[`http_router`](https://github.com/joshbuddy/http_router) or plain
[rack](https://github.com/rack/rack) routing methods) you can build a complete
web application.  However, the idea behind `web_pipe` is for it to be a
decoupled component within a web framework.  For this reason, it plays
extremely well with the [hanami](https://hanamirb.org/) &
[dry-rb](https://dry-rb.org/) ecosystems. If it helps, you can think of it as a
decoupled web controller (as the C in MVC).

`web_pipe` applications are built as a [pipe of
operations](design_model.md) on an [immutable
struct](connection_struct.md). The struct is automatically created
with data from an HTTP request, and it contains methods to
incrementally add data to generate an HTTP response. The pipe can
be [halted](connection_struct/halting_the_pipe.md) at any moment,
taking away from all operations downstream any chance to modify the
response.

`web_pipe` has a modular design, with only the minimal functionalities needed
to build a web application enabled by default. However, it ships with several
[extensions](extensions.md) to make your life easier.

Following there is a simple example. It is a web application that will check
the value of a `user` parameter. When it is `Alice` or `Joe`, it will kindly
say hello. Otherwise, it will unauthorize:

> To try this example, you can paste it to a file with the name `config.ru` and
launch the rack command `rackup` within the same directory. The application
will be available at `http://localhost:9292`.

```ruby
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
