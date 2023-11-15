# Injecting dependencies through dry-auto_inject

`web_pipe` allows injecting [plugs](`../plugging_operations/injecting_operations.md`) and [middlewares](`../using_rack_middlewares/injecting_middlewares.md`) at initialization time. As they are given as keyword arguments to the `#initialize` method, `web_pipe` is only compatible with the [keyword argument strategy from dry-auto_inject](https://dry-rb.org/gems/dry-auto_inject/main/injection-strategies/#keyword-arguments-code-kwargs-code). This is useful in the case you need to use other collaborator from your plugs' definitions.

```ruby
WebPipe.load_extensions(:params)

class CreateUserApp
  include WebPipe
  include Deps[:create_user]
  
  plug :html, WebPipe::Plugs::ContentType.('text/html')
  plug :create
  
  private
  
  def create(conn)
    create_user.(conn.params)
  end
end
```
