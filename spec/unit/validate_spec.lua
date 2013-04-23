--- validate_spec.lua
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

local validate = require("lib.snowplow.validate")
local set      = require("lib.snowplow.lib.set")

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

-- TODO: switch to using original copy of nts in validate lib
local function nts(value) -- Nil to string
  local v
  if value == nil then v = "<nil>" else v = value end
  if type(value) == "table" then v = "<table>" end
  return v
end

describe("validate", function()

  pending("nts() should work correctly")

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
      { nil                         , err("<nil>")   },
      { {}                          , err("<table>") },
      { "hello"                     , err("hello")   },
      { 23.3                        , err(23.3)      }
    }

    assertDataTable(dataTable, validate.isNonEmptyTable)
  end)

  it("isTableOrNil() should validate correctly", function()

    local err = function(value)
      return fieldName .. " must be a table or nil, not [" .. nts(value) .. "]"
    end

    local dataTable = {
      { "INPUT"                     , "EXPECTED"     },
      { { "hello" }                 , nil            },
      { { 1, 2 }                    , nil            },
      { { a = 1, b = "c"}           , nil            },
      { { a = true, b = false }     , nil            },
      { nil                         , nil            }, -- Difference from the above
      { {}                          , nil            }, -- Difference from the above
      { "hello"                     , err("hello")   },
      { 23.3                        , err(23.3)      }
    }

    assertDataTable(dataTable, validate.isTableOrNil)
  end)

  it("isNonEmptyString() should validate correctly", function()

    local err = function(value)
      return fieldName .. " is required and must be a string, not [" .. nts(value) .. "]"
    end

    local dataTable = {
      { "INPUT"                     , "EXPECTED"     },
      { "a string"                  , nil            },
      { "another"                   , nil            },
      { ""                          , err("")        },
      { nil                         , err("<nil>")   },
      { {}                          , err("<table>") },
      { { a = 1, b = c}             , err("<table>") },
      { 23.3                        , err(23.3)      }
    }

    assertDataTable(dataTable, validate.isNonEmptyString)
  end)

  it("isStringOrNil() should validate correctly", function()

    local err = function(value)
      return fieldName .. " must be a string or nil, not [" .. nts(value) .. "]"
    end

    local dataTable = {
      { "INPUT"                     , "EXPECTED"     },
      { "a string"                  , nil            },
      { "another"                   , nil            },
      { ""                          , nil            }, -- Difference from the above
      { nil                         , nil            }, -- Difference from the above
      { {}                          , err("<table>") },
      { { a = 1, b = c}             , err("<table>") },
      { 23.3                        , err(23.3)      }
    }

    assertDataTable(dataTable, validate.isStringOrNil)
  end)

  it("isStringFromSet() should validate correctly", function()

    local s = set.newSet { "a", "c", "f" }

    local err = function(value)
      return fieldName .. " must be a string from the set " .. s:toString() .. ", not [" .. nts(value) .. "]"
    end

    local setValidator = function(name, value)
      return validate.isStringFromSet(s, name, value)
    end

    local dataTable = {
      { "INPUT"                     , "EXPECTED"     },
      { "a"                         , nil            },
      { "f"                         , nil            },
      { "g"                         , err("g")       },
      { "hello"                     , err("hello")   },
      { ""                          , err("")        },
      { nil                         , err("<nil>")   },
      { {}                          , err("<table>") },
      { { a = 1, b = c}             , err("<table>") },
      { 23.3                        , err(23.3)      }
    }

    assertDataTable(dataTable, setValidator)
  end)

  it("isNumber() should validate correctly", function()

    local err = function(value)
      return fieldName .. " is required and must be a number, not [" .. nts(value) .. "]"
    end

    local dataTable = {
      { "INPUT"                     , "EXPECTED"     },
      { 23                          , nil            },
      { 0                           , nil            },
      { -10.586                     , nil            },
      { 4523000.29                  , nil            },
      { nil                         , err("<nil>")   },
      { "hello"                     , err("hello")   },
      { { a = 1, b = c}             , err("<table>") },
    }

    assertDataTable(dataTable, validate.isNumber)
  end )

  it("isNumberOrNil() should validate correctly", function()

    local err = function(value)
      return fieldName .. " must be a number or nil, not [" .. nts(value) .. "]"
    end

    local dataTable = {
      { "INPUT"                     , "EXPECTED"     },
      { 23                          , nil            },
      { 0                           , nil            },
      { -10.586                     , nil            },
      { 4523000.29                  , nil            },
      { nil                         , nil            }, -- Only difference from the above
      { "hello"                     , err("hello")   },
      { { a = 1, b = c}             , err("<table>") }
    }

    assertDataTable(dataTable, validate.isNumberOrNil)
  end)

  it("isPositiveInteger() should validate correctly", function()

    local err = function(value)
      return fieldName .. "is required and must be a positive integer, not [" .. nts(value) .. "]"
    end

    local dataTable = {
      { "INPUT"                     , "EXPECTED"     },
      { 23                          , nil            },
      { 0                           , nil            },
      { 4523000.29                  , nil            },
      { -1                          , err("-1")      },
      { -10.586                     , err("-10.586") },
      { nil                         , err("<nil>")   },
      { "hello"                     , err("hello")   },
      { { a = 1, b = c}             , err("<table>") }
    }

    assertDataTable(dataTable, validate.isPositiveInteger)
  end)

end)