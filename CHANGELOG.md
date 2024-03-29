# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.16.0] - 2021-11-07
### Added
- Extract the DSL as an optional convenience layer and introduce
  `WebPipe::Pipe` as top abstraction.
  [#47](https://github.com/waiting-for-dev/web_pipe/pull/47)
- Be able to plug anything responding to `#to_proc`.
  [#47](https://github.com/waiting-for-dev/web_pipe/pull/47)
- Be able to use anything responding to `#to_middlewares`.
  [#47](https://github.com/waiting-for-dev/web_pipe/pull/47)

## [0.15.1] - 2021-09-19
### Added
- `:not_found` extension
  [#46](https://github.com/waiting-for-dev/web_pipe/pull/46)

## [0.15.0] - 2021-09-12
### Added
- **BREAKING**. Switch `dry_view` extension with `hanami_view`.
  [#45](https://github.com/waiting-for-dev/web_pipe/pull/45)

## [0.14.0] - 2021-04-14
### Added
- Inspecting operations
  [#42](https://github.com/waiting-for-dev/web_pipe/pull/42)
- Inspecting middlewares
  [#43](https://github.com/waiting-for-dev/web_pipe/pull/43)
- Testing support
  [#44](https://github.com/waiting-for-dev/web_pipe/pull/44)

## [0.13.0] - 2021-01-15
### Added
- **BREAKING**. Ruby 2.5 deprecated.
  [#40](https://github.com/waiting-for-dev/web_pipe/pull/40)
-  Ruby 3.0 supported.
  [#41](https://github.com/waiting-for-dev/web_pipe/pull/41)

## [0.12.1] - 2019-03-18
### Fixed
- Update rake to fix security alert

## [0.12.0] - 2019-12-30
### Added
- **BREAKING**. Ruby 2.4 deprecated.
-  Ruby 2.7 supported.

### Fixed
- Ruby 2.7 argument warnings.
  [[#38]](https://github.com/waiting-for-dev/web_pipe/pull/38)

## [0.11.0] - 2019-12-28
### Added
- **BREAKING**. `dry-transformer` (former `transproc`) dependency is now
  optional.
  [[#37]](https://github.com/waiting-for-dev/web_pipe/pull/37)
- Switch `transproc` dependency to `dry-transformer`.
  [[#37]](https://github.com/waiting-for-dev/web_pipe/pull/37)

## [0.10.0] - 2019-11-15
### Added
- `:rails` extension integrating with Ruby On Rails.
  [[#36]](https://github.com/waiting-for-dev/web_pipe/pull/36)

## [0.9.0] - 2019-08-31
### Added
- Comprehensive documentation.
  [[#35]](https://github.com/waiting-for-dev/web_pipe/pull/35)

## [0.8.0] - 2019-08-30
### Added
- **BREAKING**. Rename `Rack` module to `RackSupport`.
  [[#34]](https://github.com/waiting-for-dev/web_pipe/pull/34)

## [0.7.0] - 2019-08-27
### Added
- **BREAKING**. `Conn#config` instead of `Conn#bag` for extension configuration.
  [[#29]](https://github.com/waiting-for-dev/web_pipe/pull/29)
  
- **BREAKING**. `:params` extension extracted from `:url` extension.
  [[#30]](https://github.com/waiting-for-dev/web_pipe/pull/30)
  
- **BREAKING**. Router params are extracted as a param transformation.
  [[#30]](https://github.com/waiting-for-dev/web_pipe/pull/30)
  
- **BREAKING**. Plugs now respond to `.call` instead of `.[]`.
  [[#31]](https://github.com/waiting-for-dev/web_pipe/pull/31)
  
- **BREAKING**. `:dry-schema` extension has not a default handler.
  [[#32]](https://github.com/waiting-for-dev/web_pipe/pull/32)
  
- **BREAKING**. `:dry-schema` extension stores output in `#config`.
  [[#32]](https://github.com/waiting-for-dev/web_pipe/pull/32)
  
- Integration with `transproc` gem to provide any number of params
  transformations.
  [[#30]](https://github.com/waiting-for-dev/web_pipe/pull/30)
  
- `:dry-schema` extension automatically loads `:params` extension.
  [[#32]](https://github.com/waiting-for-dev/web_pipe/pull/32)

## [0.6.1] - 2019-08-02
### Fixed
- Fixed support for ruby 2.4.
  [[#28]](https://github.com/waiting-for-dev/web_pipe/pull/28)

## [0.6.0] - 2019-08-02
### Added
- **BREAKING**. Rename `put` methods as `add`.
  [[#26]](https://github.com/waiting-for-dev/web_pipe/pull/26)

- **BREAKING**. Rename taint to halt, and clean/dirty to ongoing/halted.
  [[#25](https://github.com/waiting-for-dev/web_pipe/pull/25)]

- **BREAKING**. URL redundant methods need to be loaded from `:url` extension.
  [[#24](https://github.com/waiting-for-dev/web_pipe/pull/24)]

- Merge router params with GET and POST params.
  [[#23](https://github.com/waiting-for-dev/web_pipe/pull/23)]

- Extension integrating rack session.
  [[#21](https://github.com/waiting-for-dev/web_pipe/pull/21)]

- Extension to add/delete cookies.
  [[#20](https://github.com/waiting-for-dev/web_pipe/pull/20)] &
  [[#22](https://github.com/waiting-for-dev/web_pipe/pull/22)]

- Extension to easily create HTTP redirects.
  [[#19](https://github.com/waiting-for-dev/web_pipe/pull/19)]

- Added `Conn#set_response_headers` method.
  [[#27](https://github.com/waiting-for-dev/web_pipe/pull/27)]


## [0.5.0] - 2019-07-26
### Added
- **BREAKING**. `container` is now an extension.
  [[#16](https://github.com/waiting-for-dev/web_pipe/pull/16)]

- Extension providing Integration with `dry-schema`.
  [[#18](https://github.com/waiting-for-dev/web_pipe/pull/18)]

- No need to manually call `#to_proc` when composing plugs.
  [[#13](https://github.com/waiting-for-dev/web_pipe/pull/13)]

- Extension adding flash functionality to conn.
  [[#15](https://github.com/waiting-for-dev/web_pipe/pull/15)]

- Extensions automatically require their associated plugs, so there is no need
  to require them manually anymore.
  [[#17](https://github.com/waiting-for-dev/web_pipe/pull/17)]

### Fixed
- Fixed bug not allowing middlewares to modify responses initially set with
  default values.
  [[#14](https://github.com/waiting-for-dev/web_pipe/pull/14)]


## [0.4.0] - 2019-07-17
### Added
- **BREAKING**. Middlewares have to be named when used.
  [[#11](https://github.com/waiting-for-dev/web_pipe/pull/11)]

- **BREAKING**. Middlewares have to be initialized when composed.
  [[#11](https://github.com/waiting-for-dev/web_pipe/pull/11)]

- **BREAKING**. The array of injected plugs is now scoped within a `plugs:`
  kwarg.
  [[#11](https://github.com/waiting-for-dev/web_pipe/pull/11)]

- Middlewares can be injected.
  [[#11](https://github.com/waiting-for-dev/web_pipe/pull/11)]

- DSL helper method `compose` to add middlewares and plugs in order and in a
  single shot-
  [[#12](https://github.com/waiting-for-dev/web_pipe/pull/11)]


## [0.3.0] - 2019-07-12
### Added
- **BREAKING**. When plugging with `plug:`, the operation is no longer
  specified through `with:`. Now it is just the second positional argument-
  [[#9](https://github.com/waiting-for-dev/web_pipe/pull/9)]

- It is possible to plug a block-
  [[#9](https://github.com/waiting-for-dev/web_pipe/pull/9)]

- WebPipe plug's can be composed. A WebPipe proc representation is the
  composition of all its operations, which is an operation itself-
  [[#9](https://github.com/waiting-for-dev/web_pipe/pull/9)]

- WebPipe's middlewares can be composed into another WebPipe class-
  [[#10](https://github.com/waiting-for-dev/web_pipe/pull/10)]


## [0.2.0] - 2019-07-05
### Added
- dry-view integration-
  [[#1](https://github.com/waiting-for-dev/web_pipe/pull/1)],
  [[#3](https://github.com/waiting-for-dev/web_pipe/pull/3)],
  [[#4](https://github.com/waiting-for-dev/web_pipe/pull/4)],
  [[#5](https://github.com/waiting-for-dev/web_pipe/pull/5)] &
  [[#6](https://github.com/waiting-for-dev/web_pipe/pull/6)]

- Configuring a container in `WebPipe::Conn`-
  [[#2](https://github.com/waiting-for-dev/web_pipe/pull/2)] &
  [[#5](https://github.com/waiting-for-dev/web_pipe/pull/5)]

- Plug to set `Content-Type` response header-
  [[#7](https://github.com/waiting-for-dev/web_pipe/pull/7)]

### Fixed
- Fix key interpolation in `KeyNotFoundInBagError`-
  [[#8](https://github.com/waiting-for-dev/web_pipe/pull/8)]

## [0.1.0] - 2019-05-07
### Added
- Initial release.
