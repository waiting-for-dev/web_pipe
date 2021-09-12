# dry-rb integration

`web_pipe` has been designed to integrate smoothly with
[dry-rb](https://dry-rb.org/) ecosystem. It shares same design
principles and it ships with some extensions which even make this
integration tighter (like [`:dry-schema`](../extensions/dry_schema.md)
extension).

If you want to use `web_pipe` with the rest of dry-rb libraries,
your best bet is to use
[`dry-web-web_pipe`](https://github.com/waiting-for-dev/dry-web-web_pipe)
skeleton generator. It is a fork of
[`dry-web-roda`](https://github.com/dry-rb/dry-web-roda) with
`roda` dependency switched to a combination of `web_pipe` and
[`hanami-router`](https://github.com/hanami/router).

Look at `dry-web-web_pipe` README for more details.
