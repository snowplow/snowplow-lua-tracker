--- json_spec.lua
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

local json = require("src.snowplow..lib.json")

describe("json", function()

  it("should JSON-encode Lua tables correctly", function()

    local dataTable = {
      { "INPUT"                                                              , "EXPECTED"                                                                                           },
      { {}                                                                   , "[]"                                                                                                 },
      { { name = "John", age = 23 }                                          , '{"age":23,"name":"John"}'                                                                           },
      { { myTemp = 23.3, myUnit = "celsius"}                                 , '{"myTemp":23.3,"myUnit":"celsius"}'                                                                 },
      { { event      = "page_ping",
          mobile     = true,
          properties = { min_x = 0, max_x = 960, min_y = -12, max_y = 1080 }
        }                                                                    , '{"event":"page_ping","mobile":true,"properties":{"max_x":960,"max_y":1080,"min_x":0,"min_y":-12}}'  },
      { { event      = "basket_change",
          product_id = "PBZ000345",
          price      = 23.39,
          quantity   = -2,
          visitor    = nil, -- Sadly this doesn't make it through as "visitor": null
          tstamp     = 1678023000
        }                                                                    , '{"event":"basket_change","price":23.39,"product_id":"PBZ000345","quantity":-2,"tstamp":1678023000}' }
    }

    for i, v in ipairs(dataTable) do
      if i > 1 then
        local expected = json:encode(v[1])
        assert.are.equal(v[2], expected)
      end
    end

  end)

  it("should error on nil or other datatypes", function()

    local badValues = { nil, "", 1, "temp => 23.C", true, false, 34.5 }

    for i, v in ipairs(badValues) do
      assert.has_error(function() json:encode(v) end)
    end   

  end)

end)
