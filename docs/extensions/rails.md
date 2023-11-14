# Rails

The first two things to keep in mind to integrate with Rails are
that `WebPipe` instances are Rack applications and that rails router can
perfectly [dispatch to a rack application](https://guides.rubyonrails.org/routing.html#routing-to-rack-applications).

```ruby
# config/routes.rb
get '/my_route', to: MyRoute.new

# app/controllers/my_route.rb
class MyRoute
  include WebPipe

  plug :set_response_body

  private

  def set_response_body(conn)
    conn.set_response_body('Hello, World!')
  end
end
```

To do something like the previous example, you don't need to enable this
extension. Notice that rails dispatched the request to our `WebPipe` rack
application, which was then responsible for generating the response. In this
case, it used a simple call to `#set_response_body`.

It's quite possible that you don't need more than that in terms of rails
integration. Of course, you want something more elaborate to generate
responses. For that, you can use the view or template system you like. One
option that will play especially well here is
[`hanami-view`](https://github.com/hanami/view). Furthermore, we have a
tailored `hanami_view`
[extension](https://waiting-for-dev.github.io/web_pipe/docs/extensions/hanami_view.html).

You need to use the `:rails` extension if:

- You want to use `action_view` as a rendering system.
- You want to use rails URL helpers from your `WebPipe` application.
- You want to use controller helpers from your `WebPipe` application.

Rails' responsibilities for controlling the request/response cycle are coupled
to the rendering process. For this reason, even if you want to use `WebPipe`
applications instead of Rails controller actions you still have to use the
typical top `ApplicationController` to define some behavior for the view layer:

- Which layout is applied to the template.
- Which helpers will become available to the templates.

By default, the controller in use is `ActionController::Base`, which means that
no layout is applied and only built-in helpers (for example,
`number_as_currency`) are available. You can change it via the
`:rails_controller` configuration option.

The main method that this extension adds to `WebPipe::Conn` is `#render`, which
delegates to the [Rails implementation]
(https://api.rubyonrails.org/v6.0.1/classes/ActionController/Renderer.html) as
you'd do in a typical rails controller. Remember that you can provide template
instance variables through the keyword `:assigns`.

```ruby
# config/routes.rb
get '/articles', to: ArticlesIndex.new

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # By default uses the layout in `layouts/application`
end

# app/controllers/articles_index.rb
WebPipe.load_extensions(:rails) # You can put it in an initializer

class ArticlesIndex
  include WebPipe

  plug :config, WebPipe::Plugs::Config.(
    rails_controller: ApplicationController
  )

  def render(conn)
    conn.render(
      template: 'articles/index',
      assigns: { articles: Article.all }
    )
  end
end
```

Notice that we used the keyword `template:` instead of taking advantage of
automatic template lookup. We did that way so that we don't have to create an
`ArticlesController`, but it's up to you. In the case of having an
`ArticlesController`, we could do `conn.render(:index, assigns: { articles:
Article.all })`.

Besides, this extension provides with two other methods:

- `url_helpers` returns Rails router [url
  helpers](https://api.rubyonrails.org/v6.0.1/classes/ActionView/Helpers/UrlHelper.html).
- `helpers` returns the associated [controller
  helpers](https://api.rubyonrails.org/classes/ActionController/Helpers.html).

We have placed `WebPipe` applications within `app/controllers/` directory in
all the examples. However, remember you can put them wherever you like as long
as you respect rails
[`autoload_paths`](https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#autoload-paths).
