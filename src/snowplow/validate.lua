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

local ss = require("lib.utils").safe_string -- Alias

local validate = {}

-- --------------------------------------------------------------
-- Boolean validations

validate.is_boolean = function(name, value)
  if type(value) ~= "boolean" then
    error(name .. " is required and must be a boolean, not [" .. ss(value) .. "]")
  end
end

-- --------------------------------------------------------------
-- Table validations

validate.is_non_empty_table = function(name, value)
  if type(value) ~= "table" or next(value) == nil then
    error(name .. " is required and must be a non-empty table, not [" .. ss(value) .. "]")
  end
end

validate.is_table_or_nil = function(name, value)
  if type(value) ~= "table" and value ~= nil then
    error(name .. " must be a table or nil, not [" .. ss(value) .. "]")
  end
end

-- --------------------------------------------------------------
-- String validations

validate.is_non_empty_string = function(name, value)
  if type(value) ~= "string" or value == "" then
    error(name .. " is required and must be a non-empty string, not [" .. ss(value) .. "]")
  end
end

validate.is_non_empty_string_or_nil = function(name, value)
  local allowed_types = {
    ["nil"] = true,
    ["string"] = true,
  }
  if not allowed_types[type(value)] or value == "" then
    error(name .. " must be a non-empty string or nil, not [" .. ss(value) .. "]")
  end
end

validate.is_string_or_nil = function(name, value)
  if type(value) ~= "string" and value ~= nil then
    error(name .. " must be a string or nil, not [" .. ss(value) .. "]")
  end
end

validate.is_string_from_set = function(set, name, value)
  -- Note that set is the first argument, to support partial application.
  if type(value) ~= "string" or not set:contains(value) then
    error(name .. " must be a string from the set " .. set:to_string() .. ", not [" .. ss(value) .. "]")
  end
end

-- --------------------------------------------------------------
-- Numeric validations

validate.is_number = function(name, value)
  if type(value) ~= "number" then
    error(name .. " is required and must be a number, not [" .. ss(value) .. "]")
  end
end

validate.is_number_or_nil = function(name, value)
  if type(value) ~= "number" and value ~= nil then
    error(name .. " must be a number or nil, not [" .. ss(value) .. "]")
  end
end

validate.is_positive_integer = function(name, value)
  if type(value) ~= "number" or value ~= math.floor(value) or value < 0 then
    error(name .. " is required and must be a positive integer, not [" .. ss(value) .. "]")
  end
end

-- --------------------------------------------------------------
-- Generic validations

validate.is_type = function(expected_types, name, value)
  for _, expected_type in ipairs(expected_types) do
    if type(value) == expected_type then
      return
    end
  end
  error(name .. " must be of type " .. table.unpack(expected_types) .. ", not [" .. type(value) .. "]")
end

return validate
