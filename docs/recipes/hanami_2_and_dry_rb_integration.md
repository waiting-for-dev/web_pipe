# Hanami 2 and dry-rb integration

`web_pipe` has been designed to integrate smoothly with the
[hanami](https://hanamirb.org/) & [dry-rb](https://dry-rb.org/) ecosystems. It
shares the same design principles. It ships with some extensions that even make
this integration painless (like [`:dry-schema`](../extensions/dry_schema.md)
extension or [`:hanami_view`](../extensions/hanami_view.md)), and it seamlessly
[integrates with dry-auto_inject](injecting_dependencies_through_dry_auto_inject.md).

If you want to use `web_pipe` within a hanami 2 application, you can take
inspiration from this sample todo app:

https://github.com/waiting-for-dev/hanami_2_web_pipe_todo_app
