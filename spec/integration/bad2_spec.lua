--- bad2_spec.lua
--
-- Copyright (c) 2013 Snowplow Analytics Ltd. All rights reserved.
--
-- This program is licensed to you under the Apache License Version 2.0,
-- and you may not use this file except in compliance with the Apache License Version 2.0.
-- You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the Apache License Version 2.0 is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.
--
-- Authors:     Alex Dean
-- Copyright:   Copyright (c) 2013 Snowplow Analytics Ltd
-- License:     Apache License Version 2.0

local snowplow

describe("Integration tests with HTTP/collector problems", function()
  setup(function()
    _G._TEST = true
    package.loaded["lua_uuid"] = require("spec/mocks/mock_uuid")
    snowplow = require("snowplow")
  end)

  teardown(function()
    _G._TEST = nil
  end)

  it("should return false and an error message if a collector cannot be found", function()
    local t = snowplow.new_tracker("c.snplow.com") -- Doesn't exist
    t:platform("tv")
    t:set_screen_resolution(1068, 720)
    t:set_app_id("wow-ext-1")
    local s, msg = t:track_screen_view("Game HUD 2", nil, 1369330916)

    assert.is_false(s)
    assert.are.equal(
      msg,
      "Host [https://c.snplow.com/i?e=sv&sv_na=Game+HUD+2&dtm=1369330916000&p=tv&tv="
        .. t.config.version
        .. "&eid=00000000%2D0000%2D0000%2D0000%2D000000000000"
        .. "&aid=wow%2Dext%2D1&res=1068x720] not found (possible connectivity error)"
    )
  end)
end)
