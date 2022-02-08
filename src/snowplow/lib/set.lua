--- set.lua
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

local set = {} -- The module
local Set = {} -- The class
Set.__index = Set

-- --------------------------------------------------------------
-- Factory to create a Set

-- Creates a new set from the supplied table.
-- Source: http://www.lua.org/pil/13.1.html
-- @param t table: The table containing the values for this set
-- @return Set: The new set
function set.newSet(t)
	local s = {}
	setmetatable(s, Set)
	for _, l in ipairs(t) do
		s[l] = true
	end
	return s
end

-- --------------------------------------------------------------
-- Class methods

-- @param self Set: The set to check
-- @param value any: The value to look for in our set
-- @return boolean: If the set contains the value
function Set:contains(value)
	local c
	if self[value] == true then
		c = true
	else
		c = false
	end

	return c
end

-- Convert a set to a string representation
-- Source: http://www.lua.org/pil/13.1.html
-- @param self Set: The set to convert
-- @return string: The string representation of the set
function Set:toString()
	local s = "{"
	local sep = ""
	for e in pairs(self) do
		s = s .. sep .. e
		sep = ", "
	end
	return s .. "}"
end

-- --------------------------------------------------------------

return set
