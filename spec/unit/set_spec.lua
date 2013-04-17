--- set_spec.lua
--
-- Copyright (c) 2013 SnowPlow Analytics Ltd. All rights reserved.
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
-- Copyright:   Copyright (c) 2013 SnowPlow Analytics Ltd
-- License:     Apache License Version 2.0

local escape = require("lib.snowplow.lib.set")

local set1 = set.newSet { 1, 2, 3 }
local set2 = set.newSet { a, b, c }

describe("set", function()

  it("should compare sets correctly", function()
    local set3 = set.newSet { 1, 2, 3 }
  	assert.are.equal(set1, set3)
  	assert.are_not.equal(set1, set3)
    assert.are_not.equal(set1, { 1, 2, 3 })
  end)

  it("should know if it contains an element", function()
    assert.is.true(set1:contains(2))
    assert.is.false(set2:contains(1))
  end)

  it("should be convertable to a string", function()
    assert.are.equal(set1:toString(), "{1, 2, 3}")
    assert.are.equal(set2:toString(), "{a, b, c}")
  end)
end)