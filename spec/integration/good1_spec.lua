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

local micro = require("spec.micro.micro")
local snowplow = require("snowplow")

describe("Integration tests with no issues", function()
  local t

  before_each(function()
    micro.clear_cache()
    t = snowplow.new_tracker(micro.get_url(), "GET")
  end)

  it("should return true for a valid collector", function()
    t:encode_base64(false)
    t:set_screen_resolution(1068, 720)
    local s, msg = t:track_struct_event("name", "id")

    assert.is_true(s)
    assert.is_nil(msg)
  end)

  for _, request_type in ipairs({ "GET", "POST" }) do
    t = snowplow.new_tracker(micro.get_url(), request_type, true)

    it("can track a screen view using " .. request_type, function()
      local expected_id, expected_name = "test_id", "test_name"
      local ok, err = t:track_screen_view(expected_name, expected_id)
      assert.is_true(ok)
      assert.is_nil(err)

      local micro_event = micro.get_good_events()
      local event = micro_event[1].event.unstruct_event.data.data
      assert.are.equal(event.name, expected_name)
      assert.are.equal(event.id, expected_id)
    end)

    it("can track a struct event using " .. request_type, function()
      local expected = {
        action = "test_action",
        category = "test_category",
        label = "test_label",
        property = "test_property",
        value = 5.0,
      }

      local ok, err = t:track_struct_event(
        expected.category,
        expected.action,
        expected.label,
        expected.property,
        expected.value
      )
      assert.is_true(ok)
      assert.is_nil(err)

      local micro_event = micro.get_good_events()

      for parameter, expected_value in pairs(expected) do
        assert.are.equal(expected_value, micro_event[1].event["se_" .. parameter])
      end
    end)

    it("can track an unstruct event using " .. request_type, function()
      local ok, err = t:track_unstruct_event({
        schema = "iglu:com.snowplowanalytics.snowplow/add_to_cart/jsonschema/1-0-0",
        data = { sku = "ASO01043", unitPrice = 49.95, quantity = 1000 },
      })
      assert.is_true(ok)
      assert.is_nil(err)

      local micro_event = micro.get_good_events()
      local event = micro_event[1].event.unstruct_event.data.data

      assert.are.equal(event.sku, "ASO01043")
      assert.are.equal(event.unitPrice, 49.95)
      assert.are.equal(event.quantity, 1000)
    end)
  end

  it("creates a dvce_sent_tstamp not less than dvce_created_tstamp", function()
    local s, msg = t:track_struct_event("name", "id")
    assert.is_true(s)
    assert.is_nil(msg)

    local micro_event = micro.get_good_events()
    local event = micro_event[1].event
    assert.is_true(event.dvce_created_tstamp <= event.dvce_sent_tstamp)
  end)
end)
