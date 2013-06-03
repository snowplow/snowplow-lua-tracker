--- validate.lua
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

local ss       = require( "lib.utils" ).safeString -- Alias

local validate = {}

-- --------------------------------------------------------------
-- Boolean validations

validate.isBoolean = function(name, value)

  if type(value) ~= "boolean" then
    error(name .. " is required and must be a boolean, not [" .. ss(value) .. "]")
  end
end

-- --------------------------------------------------------------
-- Table validations

validate.isNonEmptyTable = function(name, value)

  if type(value) ~= "table" or next(value) == nil then
    error(name .. " is required and must be a non-empty table, not [" .. ss(value) .. "]")
  end
end

validate.isTableOrNil = function(name, value)

  if type(value) ~= "table" and value ~= nil then
    error(name .. " must be a table or nil, not [" .. ss(value) .. "]")
  end
end

-- --------------------------------------------------------------
-- String validations

validate.isNonEmptyString = function(name, value)

  if type(value) ~= "string" or value == "" then
    error(name .. " is required and must be a non-empty string, not [" .. ss(value) .. "]")
  end
end

validate.isStringOrNil = function(name, value)

  if type(value) ~= "string" and value ~= nil then
    error(name .. " must be a string or nil, not [" .. ss(value) .. "]")
  end
end

validate.isStringFromSet = function(set, name, value)
  --[[--
  Note that set is the first argument, to support
  partial application.
  --]]--

  if type(value) ~= "string" or not set:contains(value) then
    error(name .. " must be a string from the set " .. set:toString() .. ", not [" .. ss(value) .. "]" )
  end
end

-- --------------------------------------------------------------
-- Numeric validations

validate.isNumber = function(name, value)

  if type(value) ~= "number" then
    error(name .. " is required and must be a number, not [" .. ss(value) .. "]")
  end
end

validate.isNumberOrNil = function(name, value)

  if type(value) ~= "number" and value ~= nil then
    error(name .. " must be a number or nil, not [" .. ss(value) .. "]")
  end
end

validate.isPositiveInteger = function(name, value)

  if type(value) ~= "number" or value ~= math.floor(value) or value < 0 then
    error(name .. " is required and must be a positive integer, not [" .. ss(value) .. "]")
  end
end

-- --------------------------------------------------------------

return validate