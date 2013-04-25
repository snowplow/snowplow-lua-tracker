--- snowplow_spec.lua
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

local snowplow = require("lib.snowplow.snowplow")
local validate = require("lib.snowplow.validate")

local function assertTrackerConfig(tracker)
  assert.are.equal(t.config.encodeBase64, true)
  assert.are.equal(t.config.platform, "pc")
  assert.are.equal(t.config.version, "lua-0.1.0")
end

describe("snowplow", function()
  
  -- --------------------------------------------------------------
  -- Test private helpers

  it("_asCollectorUri() should generate a non-CloudFront Collector URI correctly", function()
    local uri = snowplow._asCollectorUri("c.snplow.com")
    assert.are.equal(uri, "http://c.snplow.com/i")
  end)

  it("_collectorUriFromCf() should generate a CloudFront Collector URI correctly", function()
    local uri = snowplow._collectorUriFromCf("d3rkrsqld9gmqf")
    assert.are.equal(uri, "http://d3rkrsqld9gmqf.cloudfront.net/i")
  end)

  -- --------------------------------------------------------------
  -- Test error handling on constructors

  it("newTrackerForUri() should error unless passed a non-empty string", function()
    local f = function(host)
      return function() snowplow.newTrackerForUri(host) end
    end
    local err = function(value)
      return "host is required and must be a string, not [" .. validate._nts(value) .. "]"
    end
    assert.has_error(f(""), err(""))
    assert.has_error(f({}), err("<table>"))
    assert.has_error(f(-23.04), err("-23.04"))
  end)

  it("newTrackerForCf() should error unless passed a non-empty string", function()
    local f = function(cfSubdomain)
      return function() snowplow.newTrackerForCf(cfSubdomain) end
    end
    local err = function(value)
      return "cfSubdomain is required and must be a string, not [" .. validate._nts(value) .. "]"
    end
    assert.has_error(f(""), err(""))
    assert.has_error(f({}), err("<table>"))
    assert.has_error(f(-23.04), err("-23.04"))
  end)

  -- --------------------------------------------------------------
  -- Verify constructed tables

  it("newTrackerForUri() should correctly create a tracker", function()

    local t = snowplow.newTrackerForUri("c.snplow.com")
    assertTrackerConfig(t)
    assert.are.equal(t.config.collectorUri, "http://c.snplow.com/i")

    -- TODO: check that we have our methods available
  end)

  it("newTrackerForCf() should correctly create a tracker", function()

    local t = snowplow.newTrackerForCf("d3rkrsqld9gmqf")
    assertTrackerConfig(t)
    assert.are.equal(uri, "http://d3rkrsqld9gmqf.cloudfront.net/i")
  end)

end)