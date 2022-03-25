--- good1_spec.lua
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
local MICRO_URL = require("spec.micro.micro_url")

describe("Integration tests with no issues", function()
  it("should return true for a valid collector", function()
    local t = snowplow.new_tracker(MICRO_URL)
    t:encode_base64(false)
    t:set_screen_resolution(1068, 720)
    local s, msg = t:track_unstruct_event(
      "save-game",
      { save_id = "4321", level = 23, difficultyLevel = "HARD", dl_content = true }
    )

    assert.is_true(s)
    assert.is_nil(msg)
  end)
end)
