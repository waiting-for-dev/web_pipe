# URL

The `:url` extension adds a few methods that process the raw URL information
into something more digestable.

Specifically, it adds:

- `#base_url`: That's schema + host + port (unless it is the default for the scheme). E.g. `'https://example.org'` or `'http://example.org:8000'`.
- `#path`: That's script name (if any) + path information. E.g. `'index.rb/users/1'` or `'users/1'`.
- `#full_path`: That's path + query string (if any). E.g. `'users/1?view=table'`.
- `#url`: That's base url + full path. E.g. `'http://example.org:8000/users/1?view=table'`.
