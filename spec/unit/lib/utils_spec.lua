--- utils_spec.lua
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

local utils = require("lib.snowplow.lib.utils")

describe("utils", function()

  it("safeString() should work correctly", function()

    local dataTable = {
      { "INPUT"            , "EXPECTED"  },
      { true               , "true"      },
      { false              , "false"     },
      { 23                 , "23"        },
      { nil                , "<nil>"     },
      { {}                 , "{}"        },
      { { a = 1, b = "2" } , "<table>"   }
    }

    for i, t in ipairs(dataTable) do
      if i > 1 then -- Skip header row
        assert.are.equal( utils.safeString( t[1] ), t[2] ) 
      end
    end

  end)
end)
