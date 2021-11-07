# Extensions

`WebPipe::Conn` features are bare-bones by default: the very minimal you need
to be able to build a web application. However, there are several extensions to
add just the ingredients you want to use progressively.

To load the extensions, you have to call `#load_extensions` method in
`WebPipe`:

```ruby
WebPipe.load_extensions(:params, :cookies)
```
