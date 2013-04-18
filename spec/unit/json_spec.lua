--- json_spec.lua
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

local json = require("lib.snowplow.lib.json")

describe("json", function()

  it("should JSON-encode Lua tables correctly", function()

    local dataTable = {
      { "INPUT"      , "EXPECTED"     },
      { {} , "{}" },
      { { name = "John", age = 23 }, "{}" },
      { { myTemp = 23.3, myUnit = "celsius"}, "{}" },
      { { event = "page_ping"}, properties = { min_x = 0, max_x = 960, min_y = -12, max_y = 1080 }, "{}" }
      { "John Smith" , "xxx" }
    }

  end)

  it("should error on nil or other datatypes", function()

    local badValues = { nil, "", 1, "temp => 23.C", true, false, 34.5 }

    -- TODO: finish this
    -- Equivalent of map in Lua?
      assert.has_error(function() base64.encode(bv) end)
  end)
end)