--- tracker_spec.lua
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

local tracker = require("tracker")

local collectorUri = "http://c.snplow.com/i"

describe("tracker", function()

  local t = tracker.newTracker( collectorUri )

  it("newTracker() should construct a new Tracker", function()
    
    -- Check these are populated
    assert.are.equal(t.collectorUri, collectorUri)
    assert.are.same(t.config, {
      encodeBase64 = true,
      platform     = "pc",
      version      = "lua-0.1.0"
      })

    -- These are not set by default
    assert.is_nil(t.appId)
    assert.is_nil(t.userId)
    assert.is_nil(t.screenResolution)
    assert.is_nil(t.viewport)
    assert.is_nil(t.colorDepth)
  end)

  it("encodeBase64() should error unless passed a boolean", function()
    local f = function() t:encodeBase64("23") end
    assert.has_error(f, "encode is required and must be a boolean, not [23]")
  end)
  it("encodeBase64() should update the Tracker's encodeBase64 configuration setting", function()
    t:encodeBase64( false )
    assert.are.equal(t.config.encodeBase64, false)
  end)

  it("platform() should error unless passed a valid platform", function()
    local f = function() t:platform("fake") end
    assert.has_error(f, "platform must be a string from the set {pc, mob, csl, tv, iot}, not [fake]")
  end)
  it("encodeBase64() should update the Tracker's encodeBase64 configuration setting", function()
    t:platform( "tv" )
    assert.are.equal(t.config.platform, "tv")
  end)

  pending("setAppId() should error unless passed a non-empty string")
  pending("setAppId() should set the Tracker's appId")

  pending("setUserId() should error unless passed a non-empty string")
  pending("setUserId() should set the Tracker's userId")

  pending("setScreenResolution() should error unless passed a pair of positive integers")
  pending("setScreenResolution() should set the Tracker's screenResolution")

  pending("setViewport() should error unless passed a pair of positive integers")
  pending("setViewport() should set the Tracker's viewport")

  pending("setColorDepth() should error unless passed a positive integer")
  pending("setColorDepth() should set the Tracker's colorDepth")

  -- TODO: note that screen res and color depth aren't attached to the event yet
end)