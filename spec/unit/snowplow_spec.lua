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

-- TODO: switch to using original copy of nts in validate lib
local function nts(value) -- Nil to string
  local v
  if value == nil then v = "<nil>" else v = value end
  if type(value) == "table" then v = "<table>" end
  return v
end

describe("snowplow", function()
  it("asCollectorUri() should generate a non-CloudFront Collector URI correctly", function()
    local uri = snowplow.asCollectorUri("c.snplow.com")
    assert.are.equal(uri, "http://c.snplow.com/i")
  end)

  it("collectorUriFromCf() should generate a CloudFront Collector URI correctly", function()
    local uri = snowplow.collectorUriFromCf("d3rkrsqld9gmqf")
    assert.are.equal(uri, "http://d3rkrsqld9gmqf.cloudfront.net/i")
  end)

  it("newTrackerForUri() should error unless passed a non-empty string", function()
    local f = function(host)
      return function() snowplow.newTrackerForUri(host) end
    end
    local err = function(value)
      return "host is required and must be a string, not [" .. nts(value) .. "]"
    end
    assert.has_error(f(""), err(""))
    assert.has_error(f({}), err("<table>"))
    assert.has_error(f(-23.04), err("-23.04"))
  end)

  pending("newTrackerForCf() should error unles passed a non-empty string")
end)