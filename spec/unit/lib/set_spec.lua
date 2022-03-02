--- set_spec.lua
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

local set = require("src.snowplow..lib.set")

local set_1 = set.new_set({ 1, 2, 3 })
local set_2 = set.new_set({ "a", "b", "c" })

describe("set", function()
  it("should compare sets correctly", function()
    local set_3 = set.new_set({ 1, 2, 3 })
    assert.are.same(set_1, set_3)
    assert.are_not.same(set_2, set_3)
    assert.are_not.same(set_1, { 1, 2, 3 })
  end)

  it("should know if it contains an element", function()
    assert.is_truthy(set_1:contains(2))
    assert.is_false(set_2:contains(1))
  end)

  it("should be convertable to a string", function()
    local set_3 = set.new_set({})
    assert.are.equal(set_1:to_string(), "{1, 2, 3}")
    assert.are_equal(set_2:to_string(), "{a, b, c}")
    assert.are.equal(set_3:to_string(), "{}")
  end)
end)
