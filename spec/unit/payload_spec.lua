--- payload_spec.lua
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

local payload = require("payload")
local json = require("lunajson")

describe("payload builder", function()
  local p

  before_each(function()
    p = payload.new_payload_builder(false)
  end)

  it("returns a new payload builder", function()
    assert.is_true(type(p.nv_pairs) == "table")
    assert.is_true(#p.nv_pairs == 0)
    assert.is_equal(p.encode_base64, false)
  end)

  it("gets the current nv_pairs", function()
    p.nv_pairs = {
      a = "b",
      c = "d",
    }
    local data = p:get()
    assert.is_equal("b", data.a)
    assert.is_equal("d", data.c)
  end)

  it("adds a key-value pair to the payload", function()
    p:add("k", "v")
    assert.is_equal("v", p:get()["k"])
  end)

  it("adds a named table to the payload", function()
    p:add_table("table_name", { k = "v" })
    assert.is_equal('{"k":"v"}', p:get()["table_name"])
  end)

  it("builds a querystring payload", function()
    p = payload.new_payload_builder(false)
    p:add("k", "v")
    p:add("num", 5)
    p:add("bool", true)
    p:add_table("table_name", { k = "v" })
    local built_payload = p:build("GET")

    local expected = {
      -- table_name is expected to be URL encoded
      table_name = "%7B%22k%22%3A%22v%22%7D",
      k = "v",
      num = "5",
      bool = "true",
    }

    -- Split on '&', ignoring the '?'
    for token in string.gmatch(built_payload:sub(2), "[^&]+") do
      local k, v = string.match(token, "([^=]+)=([^=]+)")
      assert.is_equal(expected[k], v)
    end
  end)

  it("builds a JSON payload", function()
    p = payload.new_payload_builder(false)
    p:add("k", "v")
    p:add("num", 5)
    p:add("bool", true)
    p:add_table("table_name", { k = "v" })
    local built_payload = json.decode(p:build("POST"))

    assert.is_equal(built_payload.schema, "iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-4")

    local expected_data = {
      table_name = '{"k":"v"}',
      k = "v",
      num = "5",
      bool = "true",
    }

    for k, v in pairs(expected_data) do
      assert.is_equal(v, built_payload.data[1][k])
    end
  end)
end)

describe("base64-encoded payload builder", function()
  local p

  before_each(function()
    p = payload.new_payload_builder(true)
  end)

  it("returns a new payload builder", function()
    assert.is_true(type(p.nv_pairs) == "table")
    assert.is_true(#p.nv_pairs == 0)
    assert.is_equal(p.encode_base64, true)
  end)

  it("builds a querystring payload", function()
    p:add("k", "v")
    p:add("num", 5)
    p:add("bool", true)
    p:add_table("table_name", { k = "v" })
    local built_payload = p:build("GET")
    local expected = {
      table_name = "eyJrIjoidiJ9",
      k = "v",
      num = "5",
      bool = "true",
    }

    -- Split on '&', ignoring the '?'
    for token in string.gmatch(built_payload:sub(2), "[^&]+") do
      local k, v = string.match(token, "([^=]+)=([^=]+)")
      assert.is_equal(expected[k], v)
    end
  end)

  it("builds a JSON payload", function()
    p = payload.new_payload_builder(true)
    p:add("k", "v")
    p:add("num", 5)
    p:add("bool", true)
    p:add_table("table_name", { k = "v" })
    local built_payload = p:build("POST")
    local json_payload = json.decode(built_payload)

    assert.is_equal(json_payload.schema, "iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-4")

    local expected_data = {
      table_name = "eyJrIjoidiJ9",
      k = "v",
      num = "5",
      bool = "true",
    }

    for k, v in pairs(expected_data) do
      assert.is_equal(v, json_payload.data[1][k])
    end
  end)
end)
