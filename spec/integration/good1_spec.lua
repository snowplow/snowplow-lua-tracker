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

describe("Integration tests with no issues", function()

  it("should return true for a valid CloudFront collector", function()

    local t = snowplow.newTrackerForCf( "d3rkrsqld9gmqf" )
    t:setViewport(420, 360)
    t:setUserId("user123")
    t:setAppId("wow-ext-1")
    local s, msg = t:trackStructEvent( "shop", "add-to-basket", nil, "units", 2, 1369330909 )

    -- assert.is_false(s)
    assert.is_nil(msg)
  end)

  it("should return true for a valid URI-based collector", function()

    local t = snowplow.newTrackerForUri("d3rkrsqld9gmqf.cloudfront.net") -- Technically using a CloudFront collector
    t:encodeBase64( false )
    t:setScreenResolution(1068, 720)
    local s, msg = t:trackUnstructEvent( "save-game", { save_id = "4321", level = 23, difficultyLevel = "HARD", dl_content = true }, 1369330929 )

    -- assert.is_true(s)
    assert.is_nil(msg)
  end)

end)
