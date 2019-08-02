# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased
### Added
- **BREAKING**. Rename `put` methods as `add`.
  [[#26]](https://github.com/waiting-for-dev/web_pipe/pull/26).

- **BREAKING**. Rename taint to halt, and clean/dirty to ongoing/halted.
  [[#25](https://github.com/waiting-for-dev/web_pipe/pull/25)].

- **BREAKING**. URL redundant methods need to be loaded from `:url` extension.
  [[#24](https://github.com/waiting-for-dev/web_pipe/pull/24)].

- Merge router params with GET and POST params.
  [[#23](https://github.com/waiting-for-dev/web_pipe/pull/23)].

- Extension integrating rack session.
  [[#21](https://github.com/waiting-for-dev/web_pipe/pull/21)].

- Extension to add/delete cookies.
  [[#20](https://github.com/waiting-for-dev/web_pipe/pull/20)] &
  [[#22](https://github.com/waiting-for-dev/web_pipe/pull/22)].

- Extension to easily create HTTP redirects.
  [[#19](https://github.com/waiting-for-dev/web_pipe/pull/19)].
  
- Added `Conn#set_response_headers` method.
  [[#27](https://github.com/waiting-for-dev/web_pipe/pull/27)].


## [0.5.0] - 2019-07-26
### Added
- **BREAKING**. `container` is now an extension.
  [[#16](https://github.com/waiting-for-dev/web_pipe/pull/16)].

- Extension providing Integration with `dry-schema`.
  [[#18](https://github.com/waiting-for-dev/web_pipe/pull/18)].

- No need to manually call `#to_proc` when composing plugs.
  [[#13](https://github.com/waiting-for-dev/web_pipe/pull/13)].

- Extension adding flash functionality to conn.
  [[#15](https://github.com/waiting-for-dev/web_pipe/pull/15)].

- Extensions automatically require their associated plugs, so there is no need
  to require them manually anymore.
  [[#17](https://github.com/waiting-for-dev/web_pipe/pull/17)].

### Fixed
- Fixed bug not allowing middlewares to modify responses initially set with
  default values.
  [[#14](https://github.com/waiting-for-dev/web_pipe/pull/14)].


## [0.4.0] - 2019-07-17
### Added
- **BREAKING**. Middlewares have to be named when used.
  [[#11](https://github.com/waiting-for-dev/web_pipe/pull/11)].

- **BREAKING**. Middlewares have to be initialized when composed.
  [[#11](https://github.com/waiting-for-dev/web_pipe/pull/11)].

- **BREAKING**. The array of injected plugs is now scoped within a `plugs:`
  kwarg.
  [[#11](https://github.com/waiting-for-dev/web_pipe/pull/11)].

- Middlewares can be injected.
  [[#11](https://github.com/waiting-for-dev/web_pipe/pull/11)].

- DSL helper method `compose` to add middlewares and plugs in order and in a
  single shot-
  [[#12](https://github.com/waiting-for-dev/web_pipe/pull/11)].


## [0.3.0] - 2019-07-12
### Added
- **BREAKING**. When plugging with `plug:`, the operation is no longer
  specified through `with:`. Now it is just the second positional argument-
  [[#9](https://github.com/waiting-for-dev/web_pipe/pull/9)].

- It is possible to plug a block-
  [[#9](https://github.com/waiting-for-dev/web_pipe/pull/9)].

- WebPipe plug's can be composed. A WebPipe proc representation is the
  composition of all its operations, which is an operation itself-
  [[#9](https://github.com/waiting-for-dev/web_pipe/pull/9)].

- WebPipe's middlewares can be composed into another WebPipe class-
  [[#10](https://github.com/waiting-for-dev/web_pipe/pull/10)].


## [0.2.0] - 2019-07-05
### Added
- dry-view integration-
  [[#1](https://github.com/waiting-for-dev/web_pipe/pull/1)],
  [[#3](https://github.com/waiting-for-dev/web_pipe/pull/3)],
  [[#4](https://github.com/waiting-for-dev/web_pipe/pull/4)],
  [[#5](https://github.com/waiting-for-dev/web_pipe/pull/5)] &
  [[#6](https://github.com/waiting-for-dev/web_pipe/pull/6)].

- Configuring a container in `WebPipe::Conn`-
  [[#2](https://github.com/waiting-for-dev/web_pipe/pull/2)] &
  [[#5](https://github.com/waiting-for-dev/web_pipe/pull/5)].

- Plug to set `Content-Type` response header-
  [[#7](https://github.com/waiting-for-dev/web_pipe/pull/7)].

### Fixed
- Fix key interpolation in `KeyNotFoundInBagError`-
  [[#8](https://github.com/waiting-for-dev/web_pipe/pull/8)].

## [0.1.0] - 2019-05-07
### Added
- Initial release.
