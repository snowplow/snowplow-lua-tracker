--- base64_spec.lua
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

local base64 = require("src.snowplow..lib.base64")

describe("base64", function()

  it("should Base64 encode strings correctly", function()

    local dataTable = {
      { "INPUT"                              , "EXPECTED"     },
      { "JohnSmith"                          , "Sm9oblNtaXRo"    },
      { "john+smith"                         , "am9obitzbWl0aA"   },
      { "John Smith"                         , "Sm9obiBTbWl0aA" }, 
      { '{"age":23,"name":"John"}'           , "eyJhZ2UiOjIzLCJuYW1lIjoiSm9obiJ9"},
      { '{"myTemp":23.3,"myUnit":"celsius"}' , "eyJteVRlbXAiOjIzLjMsIm15VW5pdCI6ImNlbHNpdXMifQ"},
      { '{"event":"page_ping","mobile":true,"properties":{"max_x":960,"max_y":1080,"min_x":0,"min_y":-12}}',    "eyJldmVudCI6InBhZ2VfcGluZyIsIm1vYmlsZSI6dHJ1ZSwicHJvcGVydGllcyI6eyJtYXhfeCI6OTYwLCJtYXhfeSI6MTA4MCwibWluX3giOjAsIm1pbl95IjotMTJ9fQ"},
      { '{"event":"basket_change","price":23.39,"product_id":"PBZ000345","quantity":-2,"tstamp":1678023000}',  "eyJldmVudCI6ImJhc2tldF9jaGFuZ2UiLCJwcmljZSI6MjMuMzksInByb2R1Y3RfaWQiOiJQQlowMDAzNDUiLCJxdWFudGl0eSI6LTIsInRzdGFtcCI6MTY3ODAyMzAwMH0"}
    }

    for i, v in ipairs(dataTable) do
      if i > 1 then
        local input = v[1]
        local expected = base64.encode(input)
        assert.are.equal(v[2], expected)
      end
    end

  end)

  it("should error on nil, empty strings and other datatypes", function()

    local badValues = { nil, "", 1, true, false, 34.5 }

    for i, v in pairs(badValues) do
      assert.has_error(function() base64.encode(v) end)
    end
  end)
  
end)
