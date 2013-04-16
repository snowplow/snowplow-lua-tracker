--- validate-test.lua
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

local validate = require( "validate" )

local fieldName = "TestField"

describe( "validate.isBoolean() should work correctly", function()

  local err = function ( value)
    return fieldName .. " is required and must be a boolean, not [" .. value .. "]"
  end

  local dataTable = {
    { "INPUT" , "EXPECTED"     }
    { true    , nil            },
    { false   , nil            },
    { 23      , err( 23 )      },
    { "hello" , err( "hello" ) }
  }

  for i, t in ipairs(dataTable) do
    if i > 1 then
      if t[2] == nil then
        assert.has_no.errors( validate.isBoolean( fieldName, t[1] ) )
      else
        assert.has_error( validate.isBoolean( fieldName, t[1]), t[2] )
      end
    end
  end
end )
