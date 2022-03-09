package = "SnowplowTracker"
version = "scm-1"
source = {
  url = "git://github.com/snowplow/snowplow-lua-tracker",
  tag = "TAG_SET_BY_GITHUB_ACTIONS_DO_NOT_MANUALLY_SET"
}
description = {
  summary = "Snowplow event tracker for Lua",
  detailed = [[
     With SnowplowTracker you can collect event data from your
     Lua-based applications, Lua web servers/frameworks, or
     from the Lua scripting layer within your games or apps.
  ]],
  homepage = "https://github.com/snowplow/snowplow-lua-tracker",
  license = "Apache License 2.0"
}
dependencies = {
  "lua >= 5.1",
  "lua-curl >= 0.3.13-1",
  "base64 >= 1.5-2"
}
build = {
  type = "builtin",
  modules = {
     snowplow = "src/snowplow/snowplow.lua"
  }
}
