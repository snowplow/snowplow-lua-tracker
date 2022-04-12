-- utils.lua
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

--- Helper utilities
-- @module Utils
-- @author Alex Dean
-- @copyright Copyright (c) 2013 Snowplow Analytics Ltd
-- @license Apache License Version 2.0

local utils = {}

-- --------------------------------------------------------------
-- String utils

--- Converts a value to a safe string representation.
-- @param value A value hopefully representable as a string
-- @treturn string Best-approximation string representation of the value
utils.safe_string = function(value)
  local v
  if value == nil then
    v = "<nil>"
  else
    v = value
  end
  if type(value) == "table" then
    if next(value) == nil then
      v = "{}"
    else
      v = "<table>"
    end
  end
  return tostring(v)
end

-- --------------------------------------------------------------

return utils
