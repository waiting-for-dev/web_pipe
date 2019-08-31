# URL

`:url` extension just adds a few methods which cook raw request information
about the URL into something more digestible.

Specifically, it adds:

- `#base_url`: Which is schema + host + port (unless it is the default for the scheme). I.e. `'https://example.org'` or `'http://example.org:8000'`.
- `#path`: Which is script name (if any) + path information. I.e. `'index.rb/users/1'` or `'users/1'`.
- `#full_path`: Which is path + query string (if any). I.e. `'users/1?view=table'`.
- `#url`: Which is base url + full path. I.e. `'http://example.org:8000/users/1?view=table'`.
