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

local snowplow = require("snowplow")

describe("Integration tests with HTTP/collector problems", function()
  setup(function()
    _G._TEST = true
  end)

  teardown(function()
    _G._TEST = nil
  end)

  it("should return false and an error message if a collector cannot be found", function()
    local time_spy = spy.on(os, "time")
    local t = snowplow.new_tracker("test.invalid", "GET") -- Doesn't exist
    t:platform("tv")
    t:set_screen_resolution(1068, 720)
    t:set_app_id("wow-ext-1")
    local _, msg = t:track_screen_view("Game HUD 2", nil)

    -- time returned by os.time when called in track_screen_view
    local dtm = time_spy.returnvals[1].refs[1]
    local stm = time_spy.returnvals[2].refs[1]

    local expected = {
      "Host %[https://test%.invalid/i%?",
      "e=ue",
      "dtm=" .. dtm,
      "p=tv",
      "tv=" .. t.config.version:gsub("%.", "%%."):gsub("%-", "%%-"),
      "eid=%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x", -- UUID pattern match
      "aid=wow%-ext%-1",
      "res=1068x720",
      "stm=" .. stm,
      "] not found %(possible connectivity error%)",
    }

    for _, v in ipairs(expected) do
      assert.is_true(string.find(msg, v) ~= nil)
    end
  end)
end)
