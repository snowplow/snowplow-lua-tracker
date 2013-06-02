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

local function assertTracker(status, errorMessage)

  assert.are.equal(tracker.config.encodeBase64, true)
  assert.are.equal(tracker.config.platform, "pc")
  assert.are.equal(tracker.config.version, "lua-0.1.0")
end

describe("Integration tests with HTTP/collector problems", function()

  it("should return an error if CloudFront host cannot be found", function()

    local t = snowplow.newTrackerForCf( "fake" ) -- Doesn't exist
    t:encodeBase64( false )
    t:platform( "cnsl" )
    local s, msg = t:trackStructEvent( "shop", "add-to-basket", nil, "units", 2, 1369330909 )

    assert.is_false(s)
    assert.are.equal(msg, "Host [http://fake.cloudfront.net/i?e=se&se_ca=shop&se_ac=add%2Dto%2Dbasket&se_pr=units&se_va=2&dtm=1369330909000&p=cnsl&tv=lua%2D0%2E1%2E0&tid=100000] not found (possible connectivity error)")
  end)

  it("should return an error if non-CloudFront host cannot be found", function()

    local t = snowplow.newTrackerForUri("c.snplow.com") -- Doesn't exist
    t:platform( "tv" )
    t:setScreenResolution(1068, 720)
    t:setAppId("wow-ext-1")
    local s, msg = t:trackScreenView( "Game HUD 2", nil, 1369330916 )

    assert.is_false(s)
    assert.are.equal(msg, "Host [http://c.snplow.com/i?e=sv&sv_na=Game+HUD+2&dtm=1369330916000&p=tv&tv=lua%2D0%2E1%2E0&tid=100000&aid=wow%2Dext%2D1&res=1068x720] not found (possible connectivity error)")
  end)

end)
