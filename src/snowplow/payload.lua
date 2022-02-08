--- payload.lua
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

local escape = require("lib.escape")
local json = require("lib.json")
local base64 = require("lib.base64")

local payload = {}

-- --------------------------------------------------------------
-- Factory to create a payload builder closure

payload.newPayloadBuilder = function(encodeBase64)
	-- Closure provides a fluent interface to building a new payload for Snowplow.
	-- @param encodeBase64 boolean: Whether properties and custom variables should be sent Base64 encoded or not
	-- @return table: The new payload

	local payload = "?" -- What we're closing over

	-- Helper to add a &name=value pair to our payload aka querystring. Closes around payload
	-- @param key string: The name of the property
	-- @param value string: The value to add to the payload
	-- @param esc boolean: If true, value will be escaped
	local addNvPair = function(key, value, esc)
		local a, v

		if value ~= nil and value ~= "" then
			if payload:len() > 1 then
				a = "&"
			else
				a = ""
			end
			if esc then
				v = escape.escapeUri(value)
			else
				v = value
			end
			payload = payload .. a .. key .. "=" .. v
		end
	end

	-- Converts a _non-nested_ Lua table into a JSON of properties.
	-- @param properties table: A non-nested Lua table of properties, to be converted to JSON format
	-- TODO: add validation: check for nesting etc
	-- TODO: check data types
	local toPropertiesJson = function(properties)
		local propsJson = json:encode(properties)

		-- Now we need to rename our type suffixes to fit
		-- the format expected by Snowplow
		local types = { "int", "flt", "geo", "dt", "tm", "tms" }
		for _, t in ipairs(types) do
			suffix = '":' -- To lower risk of error
			local old = "_" .. t:upper() .. suffix
			local new = "$" .. t .. suffix
			propsJson = propsJson:gsub(old, new)
		end

		return propsJson
	end

	-- Add a &name=value pair with the value encoded
	-- @param key string: The name of the property
	-- @param value string: The value to add to the payload
	-- @param validate function or nil: If present, will be called with value to validate it
	local add = function(key, value, validate)
		if type(validate) == "function" then
			validate(key, value)
		end
		addNvPair(key, value, true)
	end

	-- Add a &name=value pair with the value not encoded.
	-- @param key string: The name of the property
	-- @param value string: The value to add to the payload
	-- @param validate function or nil: If present, will be called with value to validate it
	local addRaw = function(key, value, validate)
		if type(validate) == "function" then
			validate(key, value)
		end
		addNvPair(key, value, false)
	end

	-- Add a &name=value pair with the value base64 encoded, unless encodeBase64 is set to false (in which case URI escape).
	-- @param keyIfEnc string: The key name if the value is encoded - ue_pr: Unencoded, ue_px: Encoded
	-- @param key string: The name of the property
	-- @param value string: The value to add to the payload
	-- @param validate function or nil: If present, will be called with value to validate it
	local addProps = function(keyIfEnc, key, value, validate)
		if type(validate) == "function" then
			validate((keyIfEnc .. "|" .. key), value)
		end
		props = toPropertiesJson(value)

		if encodeBase64 then
			addNvPair(keyIfEnc, base64.encode(props), false) -- Base64 encode, no URL-encoding
		else
			addNvPair(key, props, true) -- URL-encoding
		end
	end

	-- Our "builder" returns the payload string.
	-- @return string
	local build = function()
		return payload
	end

	return {
		add = add,
		addRaw = addRaw,
		addProps = addProps,
		build = build,
	}
end

-- --------------------------------------------------------------

return payload
