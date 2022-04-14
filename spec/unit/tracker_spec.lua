--- tracker_spec.lua
--
-- Copyright (c) 2013 - 2022 Snowplow Analytics Ltd. All rights reserved.
--
-- This program is licensed to you under the Apache License Version 2.0,
-- and you may not use this file except in compliance with the Apache License Version 2.0.
-- You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the Apache License Version 2.0 is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.

local tracker

local collector_url = "http://test.invalid/i"
local TRACKER_VERSION = require("constants").TRACKER_VERSION
local emitter = require("emitter")
local ss = require("lib.utils").safe_string

describe("tracker", function()
  local t
  local e = emitter.new(collector_url, "GET")

  setup(function()
    _G._TEST = true
    _G.os = require("spec/mocks/mock_os")
    package.loaded["lua_uuid"] = require("spec/mocks/mock_uuid")
    tracker = require("tracker")
  end)

  teardown(function()
    _G._TEST = nil
  end)

  before_each(function()
    t = tracker.new_tracker(e)
  end)

  -- --------------------------------------------------------------
  -- Constructor tests

  it("new_tracker() should construct a new Tracker", function()
    -- Check these are populated
    assert.are.equal(t.emitter, e)
    assert.are.same(t.config, {
      encode_base64 = true,
      platform = "pc",
      version = TRACKER_VERSION,
    })

    -- These are not set by default
    assert.is_nil(t.app_id)
    assert.is_nil(t.user_id)
    assert.is_nil(t.screen_resolution)
    assert.is_nil(t.viewport)
    assert.is_nil(t.color_depth)
  end)

  -- --------------------------------------------------------------
  -- Configuration tests

  it("encode_base64() should error unless passed a boolean", function()
    local f = function()
      t:encode_base64("23")
    end
    assert.has_error(f, "encode is required and must be a boolean, not [23]")
  end)

  it("encode_base64() should update the Tracker's encode_base64 configuration setting", function()
    t:encode_base64(false)
    assert.are.equal(t.config.encode_base64, false)
  end)

  it("platform() should error unless passed a valid platform", function()
    local f = function()
      t:platform("fake")
    end
    assert.has_error(f, "platform must be a string from the set {cnsl, iot, mob, pc, tv}, not [fake]")
  end)

  it("encode_base64() should update the Tracker's encode_base64 configuration setting", function()
    t:platform("tv")
    assert.are.equal(t.config.platform, "tv")
  end)

  -- --------------------------------------------------------------
  -- Setter tests

  it("set_app_id() should error unless passed a non-empty string", function()
    local f = function()
      t:set_app_id("")
    end
    assert.has_error(f, "app_id is required and must be a non-empty string, not []")
  end)

  it("set_app_id() should set the Tracker's app_id", function()
    t:set_app_id("wow-ext-1")
    assert.are.equal(t.app_id, "wow-ext-1")
  end)

  it("set_user_id() should error unless passed a non-empty string", function()
    local f = function()
      t:set_user_id(23)
    end
    assert.has_error(f, "user_id is required and must be a non-empty string, not [23]")
  end)

  it("set_user_id() should set the Tracker's user_id", function()
    t:set_user_id("user123")
    assert.are.equal(t.user_id, "user123")
  end)

  it("set_screen_resolution() should error unless passed a pair of positive integers", function()
    local f = function()
      t:set_screen_resolution(-20, 1078)
    end
    assert.has_error(f, "width is required and must be a positive integer, not [-20]")
  end)

  it("set_screen_resolution() should set the Tracker's screen_resolution", function()
    t:set_screen_resolution(1068, 720)
    assert.are.equal(t.screen_resolution, "1068x720")
  end)

  it("set_viewport() should error unless passed a pair of positive integers", function()
    local f = function()
      t:set_viewport(800, "1078")
    end
    assert.has_error(f, "height is required and must be a positive integer, not [1078]")
  end)

  it("set_viewport() should set the Tracker's viewport", function()
    t:set_viewport(420, 360)
    assert.are.equal(t.viewport, "420x360")
  end)

  it("set_color_depth() should error unless passed a positive integer", function()
    local f = function()
      t:set_color_depth(23.2)
    end
    assert.has_error(f, "depth is required and must be a positive integer, not [23.2]")
  end)

  it("set_color_depth() should set the Tracker's color_depth", function()
    t:set_color_depth(32)
    assert.are.equal(t.color_depth, 32)
  end)

  -- --------------------------------------------------------------
  -- track...() tests

  it("track_screen_view() should error unless name is a non-empty string", function()
    local f = function()
      t:track_screen_view(-23, "23")
    end
    assert.has_error(f, "name is required and must be a non-empty string, not [-23]")
  end)

  it("track_screen_view() should error unless id is a string or nil", function()
    local f = function()
      t:track_screen_view("Game HUD", 23)
    end
    assert.has_error(f, "id must be a non-empty string or nil, not [23]")
  end)

  it("track_struct_event() should error unless category is a non-empty string", function()
    local f = function()
      t:track_struct_event(23.2, "23")
    end
    assert.has_error(f, "category is required and must be a non-empty string, not [23.2]")
  end)

  it("track_struct_event() should error unless action is a non-empty string", function()
    local f = function()
      t:track_struct_event("shop", -456.021)
    end
    assert.has_error(f, "action is required and must be a non-empty string, not [-456.021]")
  end)

  it("track_struct_event() should error unless label is a string or nil", function()
    local f = function()
      t:track_struct_event("shop", "add-to-basket", {})
    end
    assert.has_error(f, "label must be a string or nil, not [{}]")
  end)

  it("track_struct_event() should error unless property is a string or nil", function()
    local f = function()
      t:track_struct_event("shop", "add-to-basket", nil, 23)
    end
    assert.has_error(f, "property must be a string or nil, not [23]")
  end)

  it("track_screen_event() should error unless value is a number or nil", function()
    local f = function()
      t:track_struct_event("shop", "add-to-basket", nil, "units", "212")
    end
    assert.has_error(f, "value must be a number or nil, not [212]")
  end)

  it("track_self_describing_event() should error if schema is not a non-empty string", function()
    local f = function(schema, data)
      t:track_self_describing_event(schema, data)
    end

    local incorrect_schemas = {
      { "", { key = "value" } },
      { 1, { key = "value" } },
      { true, { key = "value" } },
      { {}, { key = "value" } },
    }
    for _, args in ipairs(incorrect_schemas) do
      assert.has_error(function()
        f(args[1], args[2])
      end, "schema is required and must be a non-empty string, not [" .. ss(args[1]) .. "]")
    end
  end)

  it("track_self_describing_event() should error if data is not a non-empty table", function()
    local f = function(schema, data)
      t:track_self_describing_event(schema, data)
    end

    local incorrect_data = {
      { "iglu:example/schema", "" },
      { "iglu:example/schema", 1 },
      { "iglu:example/schema", true },
      { "iglu:example/schema", {} },
    }

    for _, args in ipairs(incorrect_data) do
      assert.has_error(function()
        f(args[1], args[2])
      end, "data is required and must be a non-empty table, not [" .. ss(args[2]) .. "]")
    end
  end)
end)
