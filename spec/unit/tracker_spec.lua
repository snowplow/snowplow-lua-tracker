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

local tracker

local collector_uri = "http://test.invalid/i"
local TRACKER_VERSION = require("constants").TRACKER_VERSION

describe("tracker", function()
  setup(function()
    _G._TEST = true
    _G.os = require("spec/mocks/mock_os")
    package.loaded["lua_uuid"] = require("spec/mocks/mock_uuid")
    tracker = require("tracker")
  end)

  teardown(function()
    _G._TEST = nil
  end)

  local t
  before_each(function()
    t = tracker.new_tracker(collector_uri)
  end)

  -- --------------------------------------------------------------
  -- Constructor tests

  it("new_tracker() should construct a new Tracker", function()
    -- Check these are populated
    assert.are.equal(t.collector_uri, collector_uri)
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
    assert.has_error(f, "sv_na is required and must be a non-empty string, not [-23]")
  end)

  it("track_screen_view() should error unless id is a string or nil", function()
    local f = function()
      t:track_screen_view("Game HUD", 23)
    end
    assert.has_error(f, "sv_id must be a string or nil, not [23]")
  end)

  it("track_screen_view() should call http_get() with the correct payload in the querystring", function()
    stub(t, "_http_get")
    t:set_user_id("user123")
    t:set_app_id("wow-ext-1")
    t:platform("tv")
    t:set_color_depth(32)
    t:set_screen_resolution(1068, 720)
    t:set_viewport(420, 360)

    t:track_screen_view("Game HUD 2", nil)
    assert.stub(t._http_get).was_called_with(
      "http://test.invalid/i?e=sv&sv_na=Game+HUD+2&dtm=1000000000000&p=tv&tv="
        .. t.config.version
        .. "&eid=00000000%2D0000%2D0000%2D0000%2D000000000000"
        .. "&uid=user123&aid=wow%2Dext%2D1&res=1068x720&vp=420x360&cd=32"
    )
  end)

  it("track_struct_event() should error unless category is a non-empty string", function()
    local f = function()
      t:track_struct_event(23.2, "23")
    end
    assert.has_error(f, "se_ca is required and must be a non-empty string, not [23.2]")
  end)

  it("track_struct_event() should error unless action is a non-empty string", function()
    local f = function()
      t:track_struct_event("shop", -456.021)
    end
    assert.has_error(f, "se_ac is required and must be a non-empty string, not [-456.021]")
  end)

  it("track_struct_event() should error unless label is a string or nil", function()
    local f = function()
      t:track_struct_event("shop", "add-to-basket", {})
    end
    assert.has_error(f, "se_la must be a string or nil, not [{}]")
  end)

  it("track_struct_event() should error unless property is a string or nil", function()
    local f = function()
      t:track_struct_event("shop", "add-to-basket", nil, 23)
    end
    assert.has_error(f, "se_pr must be a string or nil, not [23]")
  end)

  it("track_screen_event() should error unless value is a number or nil", function()
    local f = function()
      t:track_struct_event("shop", "add-to-basket", nil, "units", "212")
    end
    assert.has_error(f, "se_va must be a number or nil, not [212]")
  end)

  it("track_struct_event() should call http_get() with the correct payload in the querystring", function()
    stub(t, "_http_get")
    t:set_user_id("user123")
    t:set_app_id("wow-ext-1")
    t:platform("tv")
    t:set_color_depth(32)
    t:set_screen_resolution(1068, 720)
    t:set_viewport(420, 360)
    t:track_struct_event("shop", "add-to-basket", nil, "units", 2)
    assert.stub(t._http_get).was_called_with(
      "http://test.invalid/i?e=se&se_ca=shop&se_ac=add%2Dto%2Dbasket&se_pr=units&se_va=2"
        .. "&dtm=1000000000000&p=tv&tv="
        .. t.config.version
        .. "&eid=00000000%2D0000%2D0000%2D0000%2D000000000000&uid=user123&aid=wow%2Dext%2D1&res=1068x720&vp=420x360"
        .. "&cd=32"
    )
  end)

  it("track_unstruct_event() should call http_get() with the correct URL-encoded payload in the querystring", function()
    stub(t, "_http_get")
    t:encode_base64(false)
    t:set_user_id("user123")
    t:set_app_id("wow-ext-1")
    t:platform("tv")
    t:set_color_depth(32)
    t:set_screen_resolution(1068, 720)
    t:set_viewport(420, 360)
    t:track_unstruct_event(
      "save-game",
      { save_id = "4321", level_INT = 23, difficultyLevel = "HARD", dl_content = true }
    )
    assert.stub(t._http_get).was_called_with(
      "http://test.invalid/i?e=ue&ue_na=save%2Dgame&ue_pr=%7B%22difficultyLevel%22%3A%22HARD%22%2C%22"
        .. "dl%5Fcontent%22%3Atrue%2C%22level%24int%22%3A23%2C%22save%5Fid%22%3A%224321%22%7D&dtm=1000000000000&p=tv"
        .. "&tv="
        .. t.config.version
        .. "&eid=00000000%2D0000%2D0000%2D0000%2D000000000000&"
        .. "uid=user123&aid=wow%2Dext%2D1&res=1068x720&vp=420x360&cd=32"
    )
  end)

  it(
    "track_unstruct_event() should call http_get() with the correct Base64-encoded payload in the querystring",
    function()
      stub(t, "_http_get")
      t:encode_base64(true)
      t:set_user_id("user123")
      t:set_app_id("wow-ext-1")
      t:platform("tv")
      t:set_color_depth(32)
      t:set_screen_resolution(1068, 720)
      t:set_viewport(420, 360)
      t:track_unstruct_event(
        "load-game",
        { save_id = "4321", level_INT = 23, difficultyLevel = "HARD", dl_content = true }
      )
      assert.stub(t._http_get).was_called_with(
        "http://test.invalid/i?e=ue&ue_na=load%2Dgame&ue_px=eyJkaWZmaWN1bHR5TGV2ZWwiOiJIQVJEIiwiZGxfY2"
          .. "9udGVudCI6dHJ1ZSwibGV2ZWwkaW50IjoyMywic2F2ZV9pZCI6IjQzMjEifQ==&dtm=1000000000000&p=tv&tv="
          .. t.config.version
          .. "&eid=00000000%2D0000%2D0000%2D0000%2D000000000000"
          .. "&uid=user123&aid=wow%2Dext%2D1&res=1068x720&vp=420x360&cd=32"
      )
    end
  )
end)
