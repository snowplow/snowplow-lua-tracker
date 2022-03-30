--- bad1_spec.lua
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
local micro = require("spec.micro.micro")

describe("Integration tests with bad config", function()
  it("should throw an error on a bad configuration option", function()
    local t = snowplow.new_tracker(micro.get_url())
    t:encode_base64(false)
    t:platform("tv")

    local f = function()
      t:set_color_depth("unknown")
    end
    assert.has_error(f, "depth is required and must be a positive integer, not [unknown]")
  end)

  it("should throw an error without impacting another tracker", function()
    local t1 = snowplow.new_tracker(micro.get_url())
    t1:platform("tv")
    assert.has_no.errors(function()
      t1:track_screen_view("Game HUD", "23")
    end)
    assert.has_no.errors(function()
      t1:track_unstruct_event("save-game", { save_id = 23 })
    end)

    local t2 = snowplow.new_tracker("test.invalid")
    t2:encode_base64(false)
    t2:platform("iot")
    t2:set_color_depth(32)
    t2:set_viewport(1028, 760)

    local f = function()
      t2:set_user_id(true)
    end
    assert.has_error(f, "user_id is required and must be a non-empty string, not [true]")

    t1:platform("iot") -- Redefine
    t1:encode_base64(false) -- Redefine
    assert.has_no.errors(function()
      t1:track_screen_view("Test", "23")
    end)
    assert.has_no.errors(function()
      t1:track_struct_event("hud", "save", nil, nil, nil)
    end)
  end)

  it("should be reusable if the error is caught", function()
    local t1 = snowplow.new_tracker(micro.get_url())
    t1:encode_base64(false)
    local status, err = pcall(t1.platform, t1, false)
    assert.are.equal(status, false)
    assert.is_not_nil(err:find("platform must be a string from the set {cnsl, iot, mob, pc, tv}, not %[false%]"))

    assert.has_no.errors(function()
      t1:platform("cnsl")
    end)
    assert.has_no.errors(function()
      t1:track_screen_view("Test", "23")
    end)
  end)
end)
