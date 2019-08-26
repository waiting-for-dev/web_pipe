# Halting the pipe

You now that each operation in the pipe takes a single
`WebPipe::Conn` instance as argument and must return another (or
the same) instance of it. In this way, you propagate a series of
operations on the connection struct until you eventually create the
response you want.

More often than not, you may need to conditionally stop the
propagation of a pipe at a given operation. A lot of times the
requirement to do something like that will be authorization
policies. For example, you fetch the user requesting the resource.
If she is granted to perform required action you go on. Otherwise,
you halt the connection and respond with an unauthorized http
status code.

In order to stop the pipe, you simply have to call `#halt` on the
connection struct.

At the implementation level, we must admit that we've not been 100%
accurate until now.  We said that the first operation in the pipe
was provided with a `WebPipe::Conn` instance. That's true. However,
it is more precise to say that it gets a `WebPipe::Conn::Ongoing`
instance (`WebPipe::Conn::Ongoing` being a subclass of
`WebPipe::Conn`).

As long as an operation responds with a `WebPipe::Conn::Ongoing`
instance, the propagation will go on. However, when an operation
returns a `WebPipe::Conn::Halted` instance (another subclass of
`WebPipe::Conn`) then any operation downstream will be ignored.
Calling `#halt` simply copies all the attributes to a
`WebPipe::Conn::Halted` instance and returns it.

This made-up example checks if the user in the request has an admin role. If she does, it returns solicited resource. Otherwise she is unauthorized and never gets the resource.

```ruby
WebPipe.load_extensions(:params)

class ShowTaskApp
  include WebPipe
  
  plug :fetch_user
  plug :authorize
  plug :render_task
  
  private
  
  def fetch_user(conn)
    conn.add(
      :user, UserRepo.find(conn.params[:user_id])
    )
  end
  
  def authorize(conn)
    if conn.fetch(:user).admin?
      conn
    else
      conn.
        set_status(401).
        halt
    end
  end
  
  def render_task(conn)
    conn.set_response_body(
      TaskRepo.find(conn.params[:id]).to_json
    )
  end
end

run ShowTaskApp.new
```
