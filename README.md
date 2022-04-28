# Lua Analytics for Snowplow

[![early-release]][tracker-classification]
[![Build Status][gh-actions-image]][gh-actions]
[![License][license-image]][license]

## Overview

Add analytics to your Lua apps and Lua-scripted games with the [Snowplow][snowplow] event tracker for [Lua][lua].

With this tracker you can collect event data from your Lua-based applications, Lua web servers/frameworks, or from the Lua scripting layer within your games or apps.

## Maintainer quick start

### Build Requirements

Ensure you have the following installed on your system:

- [Lua](https://www.lua.org/) version >= 5.1
- [Luarocks](https://luarocks.org/) (Lua's dependency manager)
- curl

If using `brew`, simply run:

```sh
brew install lua luarocks curl
```

### Installing dependencies

```sh
luarocks install snowplowtracker-0.2.0-1 --deps-only
```

**_Note:_** There are two path args you may need to pass in if luarocks cannot find them,  `CURL_DIR`, and `UUID_DIR`.

An example if curl was installed via `brew`, depending on your architecture:

#### Intel MacOS

```sh
luarocks install snowplowtracker-scm-1.rockspec --deps-only CURL_DIR=/usr/local/Cellar/curl/7.81.0
```

#### ARM MacOS

```sh
luarocks install snowplowtracker-scm-1.rockspec --deps-only CURL_DIR=/opt/homebrew/opt/curl
```

### Building the project

With all dependencies installed, run:

```sh
luarocks build
```

## Tests

To run tests, you will need `busted`:

```sh
luarocks install busted
```

These tests require a Snowplow collector, so there are a couple of ways you're able to run them:

### run-test script

This script will handle downloading and running [Micro](https://github.com/snowplow-incubator/snowplow-micro) for the tests, you just need to run:

```sh
./run-tests
```

You are able to use any `busted` arguments with this script, for example:

```sh
./run-tests --pattern=tracker_spec.lua
```

### Running with your own collector

You are also able to run these tests with any collector by setting the `MICRO_URL` envvar to the collector URL, and then running `busted`:

```sh
set MICRO_URL=http://localhost:9090
busted
```

## Luacheck

[Luacheck](https://github.com/lunarmodules/luacheck), a static analyser, is used with this project. To check all files, first install luacheck:

```sh
luarocks install luacheck
```

Then run:

```sh
luacheck .
```

## Find out more

|         Snowplow Docs         |       Setup Guide        |           Contributing           |
| :---------------------------: | :----------------------: | :------------------------------: |
|     ![i1][techdocs-image]     |    ![i2][setup-image]    |    ![i4][contributing-image]     |
| **[Snowplow Docs][techdocs]** | **[Setup Guide][setup]** | **[Contributing][contributing]** |

## Contributing

Feedback and contributions are welcome - if you have identified a bug, please log an issue on this repo. For all other feedback, discussion or questions please open a thread on our [Discourse][discourse] forum.

## Copyright and license

The Snowplow Lua Tracker is copyright 2013 - 2022 Snowplow Analytics Ltd.

Licensed under the **[Apache License, Version 2.0][license]** (the "License");
you may not use this software except in compliance with the License.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[lua]: http://www.lua.org/
[snowplow]: http://snowplowanalytics.com
[discourse]: https://discourse.snowplowanalytics.com

[license]: https://www.apache.org/licenses/LICENSE-2.0
[license-image]: https://img.shields.io/badge/license-Apache--2-blue.svg?style=flat

[gh-actions]: https://github.com/snowplow/snowplow-ruby-tracker/actions
[gh-actions-image]: https://github.com/snowplow/snowplow-ruby-tracker/workflows/Test/badge.svg

[techdocs-image]: https://d3i6fms1cm1j0i.cloudfront.net/github/images/techdocs.png
[setup-image]: https://d3i6fms1cm1j0i.cloudfront.net/github/images/setup.png
[contributing-image]: https://d3i6fms1cm1j0i.cloudfront.net/github/images/contributing.png

[techdocs]: https://docs.snowplowanalytics.com/docs/collecting-data/collecting-from-own-applications/lua-tracker/
[setup]: https://docs.snowplowanalytics.com/docs/collecting-data/collecting-from-own-applications/lua-tracker/
[contributing]: https://github.com/snowplow/snowplow/wiki/Lua-Tracker-Contributing

[license]: http://www.apache.org/licenses/LICENSE-2.0

[tracker-classification]: https://docs.snowplowanalytics.com/docs/collecting-data/collecting-from-own-applications/tracker-maintenance-classification/
[early-release]: https://img.shields.io/static/v1?style=flat&label=Snowplow&message=Early%20Release&color=014477&labelColor=9ba0aa&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAeFBMVEVMaXGXANeYANeXANZbAJmXANeUANSQAM+XANeMAMpaAJhZAJeZANiXANaXANaOAM2WANVnAKWXANZ9ALtmAKVaAJmXANZaAJlXAJZdAJxaAJlZAJdbAJlbAJmQAM+UANKZANhhAJ+EAL+BAL9oAKZnAKVjAKF1ALNBd8J1AAAAKHRSTlMAa1hWXyteBTQJIEwRgUh2JjJon21wcBgNfmc+JlOBQjwezWF2l5dXzkW3/wAAAHpJREFUeNokhQOCA1EAxTL85hi7dXv/E5YPCYBq5DeN4pcqV1XbtW/xTVMIMAZE0cBHEaZhBmIQwCFofeprPUHqjmD/+7peztd62dWQRkvrQayXkn01f/gWp2CrxfjY7rcZ5V7DEMDQgmEozFpZqLUYDsNwOqbnMLwPAJEwCopZxKttAAAAAElFTkSuQmCC
