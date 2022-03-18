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

local snowplow = require("snowplow")
local ss = require("lib.utils").safe_string -- Alias
local TRACKER_VERSION = require("constants").TRACKER_VERSION

local function assert_tracker(tracker, collector_uri)
  assert.are.equal(tracker.collector_uri, collector_uri)
  assert.are.equal(tracker.config.encode_base64, true)
  assert.are.equal(tracker.config.platform, "pc")
  assert.are.equal(tracker.config.version, TRACKER_VERSION)
end

describe("snowplow", function()
  -- --------------------------------------------------------------
  -- Test error handling on constructors

  it("new_tracker() should error unless passed a non-empty string", function()
    local f = function(host)
      return function()
        snowplow.new_tracker(host)
      end
    end
    local err = function(value)
      return "url is required and must be a non-empty string, not [" .. ss(value) .. "]"
    end
    assert.has_error(f(""), err(""))
    assert.has_error(f({}), err("{}"))
    assert.has_error(f(-23.04), err("-23.04"))
  end)

  -- --------------------------------------------------------------
  -- Verify constructed tracker tables

  it("new_tracker() should correctly create a tracker", function()
    local t = snowplow.new_tracker("test.invalid")
    assert_tracker(t, "https://test.invalid/i")
  end)

  it("new_tracker_for_uri() should correctly assign default protocol https", function()
    local t = snowplow.new_tracker("test.invalid")
    assert.is_equal(t.collector_uri:sub(1, 5), "https")
  end)

  it("new_tracker_for_uri() should correctly create url with default protocol from url with port", function()
    local t = snowplow.new_tracker("http://test.invalid:9090")
    assert.is_equal("http://test.invalid:9090/i", t.collector_uri)
  end)

  it("new_tracker() should assign correct passed protocol", function()
    local protocols = { "http", "https" }
    for _, protocol in ipairs(protocols) do
      local t = snowplow.new_tracker(protocol .. "://test.invalid")
      assert.is_equal(t.collector_uri:sub(1, protocol:len()), protocol)
    end
  end)

  it("new_tracker() should error if passed an invalid protocol", function()
    local protocols = { "ftp", "file" }
    for _, protocol in ipairs(protocols) do
      local f = function()
        snowplow.new_tracker(protocol .. "://test.invalid")
      end
      assert.has_error(f, "protocol must be a string from the set {http, https}, not [" .. protocol .. "]")
    end
  end)
end)
