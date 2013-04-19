--- validate_spec.lua
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

local validate = require("lib.snowplow.validate")

local fieldName = "TestField"

local function assertDataTable(dataTable, validator)
  for i, t in ipairs(dataTable) do
    local f = function () validator(fieldName, t[1]) end

    if i > 1 then
      if t[2] == nil then
        assert.has_no.errors(f)   
      else
        assert.has_error(f, t[2])
      end
    end
  end
end

local function nts(value) -- Nil to string
  local v
  if value == nil then v = "<nil>" else v = value end
  if type(value) == "table" then v = "<table>" end
  return v
end

describe("validate", function()

  it("isBoolean() should validate correctly", function()

    local err = function(value)
      return fieldName .. " is required and must be a boolean, not [" .. nts(value) .. "]"
    end

    local dataTable = {
      { "INPUT" , "EXPECTED"   },
      { true    , nil          },
      { false   , nil          },
      { 23      , err(23)      },
      { "hello" , err("hello") }
    }

    assertDataTable(dataTable, validate.isBoolean)
  end )

  it("isNonEmptyTable() should validate correctly", function()

    local err = function(value)
      return fieldName .. " is required and must be a non-empty table, not [" .. nts(value) .. "]"
    end

    local dataTable = {
      { "INPUT"                     , "EXPECTED"     },
      { { "hello" }                 , nil            },
      { { 1, 2 }                    , nil            },
      { { a = 1, b = c}             , nil            },
      { { a = true, b = false }     , nil            },
      { {}                          , err("<table>") },
      { "string"                    , err("string")  },
      { nil                         , err("<nil>")   },
      { 23.3                        , err(23.3)      }
    }

    assertDataTable(dataTable, validate.isNonEmptyTable)
  end)

end)