package = "SnowplowTracker"
version = "1.0-1"
source = {
  url = "https://github.com/snowplow/snowplow-lua-tracker"
}
description = {
  summary = "Snowplow event tracker for Lua",
  detailed = [[
     With SnowplowTracker you can collect event data from your
     Lua-based applications, Lua web servers/frameworks, or
     from the Lua scripting layer within your games or apps.
  ]],
  homepage = "https://github.com/snowplow/snowplow-lua-tracker",
  license = "Apache License Version 2.0"
}
dependencies = {
  "lua ~> 5.1",
  -- TODO: add luasockets dependency
}
build = {
  -- TODO: add here
}