# Extensions

`WebPipe::Conn` features are by default raw: the very minimal you
need to be able to build a web application. However, there are
several extensions to progressively add just the ingredients you
want to use.

In order to load the extensions, you have to call
`#load_extensions` method in `WebPipe`:

```ruby
WebPipe.load_extensions(:params, :cookies)
```
