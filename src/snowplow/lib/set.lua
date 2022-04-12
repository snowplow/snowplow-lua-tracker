-- set.lua
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

--- A simple set implementation.
-- @module Set
-- @author Alex Dean
-- @copyright Copyright (c) 2013 Snowplow Analytics Ltd
-- @license Apache License Version 2.0

--- The set table.
-- @func new_set
-- @func contains
-- @func to_string
-- @table Set

local set = {} -- The module
local Set = {} -- The class
Set.__index = Set

-- --------------------------------------------------------------
-- Factory to create a Set

--- Creates a new set from the supplied table.
-- Source: http://www.lua.org/pil/13.1.html
-- @tab t The table containing the values for this set
-- @treturn Set The new set
function set.new_set(t)
  local s = {}
  setmetatable(s, Set)
  for _, l in ipairs(t) do
    s[l] = true
  end
  return s
end

-- --------------------------------------------------------------
-- Private methods

-- Creates an iterator over the set in key-sorted order.
-- @Set s The set to iterate over
-- @t func The iterator function
local function pairs_by_keys(s)
  local a = {}
  for n in pairs(s) do
    table.insert(a, n)
  end
  table.sort(a)
  local i = 0
  local iter = function()
    i = i + 1
    if a[i] == nil then
      return nil
    else
      return a[i]
    end
  end
  return iter
end

-- --------------------------------------------------------------
-- Class methods

--- Checks if a value is in the set.
-- @param value The value to look for in our set
-- @treturn bool If the set contains the value
function Set:contains(value)
  local c
  if self[value] == true then
    c = true
  else
    c = false
  end

  return c
end

--- Convert a set to a string key-sorted string representation
-- Source: http://www.lua.org/pil/13.1.html
-- @treturn string The string representation of the set
function Set:to_string()
  local s = "{"
  local sep = ""
  for e in pairs_by_keys(self) do
    s = s .. sep .. e
    sep = ", "
  end
  return s .. "}"
end

-- --------------------------------------------------------------

return set
