# Cookies

Extension helping to deal with request and response cookies.

Remember, cookies are just the value of `Set-Cookie` header.

This extension adds following methods:

- `#request_cookies`: Returns request cookies

- `#set_cookie(key, value)` or `#set_cookie(key, value, options)`: Instructs
  browser to add a new cookie with given key and value.
  
  Some options can be given as keyword arguments (see [MDN reference on
  cookies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies) for an
  explanation):

  - `domain:` must be a string.
  - `path:` must be a string.
  - `max_age:` must be an integer with the number of seconds.
  - `expires:` must be a `Time`.
  - `secure:` must be `true` or `false`.
  - `http_only:` must be `true` or `false`.
  - `same_site:` must be one of the symbols `:none`, `:lax` or `:strict`.

- `#delete_cookie(key)` or `#delete_cookie(key, options)`: Instructs browser to
  delete a previously sent cookie.
  
  Deleting a cookie just means setting again the same key with an expiration
  time in the past.
  
  It accepts `domain:` and `path:` options (see above for a description of
  them).

Example:
  
```ruby
require 'web_pipe'

WebPipe.load_extensions(:cookies)

class MyApp
  include WebPipe
  
  plug(:set_cookie) do |conn|
    conn.set_cookie('foo', 'bar', secure: true, http_only: true)
  end
end
```
