--- escape_spec.lua
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

local escape = require("src.snowplow..lib.escape")

describe("escape.escapeUri()", function()

  it("should URI-escape strings correctly", function()

    local dataTable = {
      { "INPUT"      , "EXPECTED"     },
      { "JohnSmith"  , "JohnSmith"    },
      { "john+smith" , "john%2Bsmith" },
      { "John Smith" , "John+Smith"   }
    }

    for i, v in ipairs(dataTable) do
      if i > 1 then
        local expected = escape.escapeUri(v[1])
        assert.are.equal(v[2], expected)
      end
    end

  end)
  
end)
