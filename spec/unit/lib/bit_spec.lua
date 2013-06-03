--- bit_spec.lua
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

require("src.snowplow..lib.bit")

describe("subset of bit used in base64", function()

  it("band() should work", function()
  	assert.are.equal(bit.band(0x0111, 0x1101), 0x0101)
  end)
  it("bor() should work", function()
  	assert.are.equal(bit.bor(0x0111, 0x1101), 0x1111)
  end)
  it("blshift() should work", function()
  	assert.are.equal(bit.blshift(0xff, 4), 0xff0)
  end)
  it("blogic_rshift() should work", function()
  	assert.are.equal(bit.blogic_rshift(0xffffff, 4), 0xfffff)
  end) 

end)
