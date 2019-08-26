[![Gem Version](https://badge.fury.io/rb/web_pipe.svg)](https://badge.fury.io/rb/web_pipe)
[![Build Status](https://travis-ci.com/waiting-for-dev/web_pipe.svg?branch=master)](https://travis-ci.com/waiting-for-dev/web_pipe)

# WebPipe

1. [Introduction](docs/introduction.md)
2. [Design model](docs/design_model.md)
3. [Building a rack application](docs/building_a_rack_application.md)
4. [Plugging operations](docs/plugging_operations.md)
   1. [Resolving operations](docs/plugging_operations/resolving_operations.md)
   2. [Injecting operations](docs/plugging_operations/injecting_operations.md)
   3. [Composing operations](docs/plugging_operations/composing_operations.md)
5. [Using rack middlewares](docs/using_rack_middlewares.md)
   1. [Injecting middlewares](docs/using_rack_middlewares/injecting_middlewares.md)
   2. [Composing middlewares](docs/using_rack_middlewares/composing_middlewares.md)
6. [Composing applications](docs/composing_applications.md)
7. [Connection struct](docs/connection_struct.md)
   1. [Sharing data downstream](docs/connection_struct/sharing_data_downstream.md)
   2. [Halting the pipe](docs/connection_struct/halting_the_pipe.md)
   3. [Configuring the connection struct](docs/connection_struct/configuring_the_connection_struct.md)
8. [DSL free usage](docs/dsl_free_usage.md)
9. [Plugs](docs/plugs.md)
   1. [ContentType](docs/plugs/content_type.md)
   2. [Config](docs/plugs/config.md)
10. [Extensions](docs/extensions.md)

## Current status

`web_pipe` is in active development. The very basic features to build
a rack application are all available. However, very necessary
conveniences to build a production application, for example a session
mechanism, are still missing.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/waiting-for-dev/web_pipe.

## Release Policy

`web_pipe` follows the principles of [semantic versioning](http://semver.org/).
