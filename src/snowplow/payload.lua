-- payload.lua
--
-- Copyright (c) 2013 - 2022 Snowplow Analytics Ltd. All rights reserved.
--
-- This program is licensed to you under the Apache License Version 2.0,
-- and you may not use this file except in compliance with the Apache License Version 2.0.
-- You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the Apache License Version 2.0 is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.

--- A builder for a Snowplow payload, can be used to construct either
-- a querystring for a GET request, or to create a JSON body for a POST request.
-- @module Payload
-- @author Alex Dean
-- @copyright Copyright (c) 2013 - 2022 Snowplow Analytics Ltd
-- @license Apache License Version 2.0

local json = require("lunajson")
local validate = require("validate")
local base64 = require("base64")
local urlencode = require("urlencode")

--- The Payload table.
-- @func add
-- @func add_table
-- @func get
-- @func build
-- @table Payload

local Payload = {}
local payload = {}

-- --------------------------------------------------------------
-- Private methods

-- Builds a querystring payload
-- @tab payload_table The payload table
-- @treturn string The querystring payload
local function build_querystring(payload_table)
  local querystring = "?"
  for k, v in pairs(payload_table) do
    querystring = querystring .. tostring(k) .. "=" .. urlencode.encode_url(tostring(v)) .. "&"
  end
  -- Remove trailing '&'
  return querystring:sub(1, -2)
end

-- Builds a JSON payload
-- @tab payload_table The payload table
-- @treturn string The JSON payload
local function build_json(payload_table)
  return json.encode({
    schema = "iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-4",
    data = { payload_table },
  })
end

-- --------------------------------------------------------------
-- Public methods

--- Adds a key, value pair to the payload table
-- @tparam string|number|bool key The key to add
-- @string value The value to add
function Payload:add(key, value)
  validate.is_type({ "string", "number", "boolean" }, "value", value)
  self.nv_pairs[key] = tostring(value)
end

--- Adds a named table to the payload table
-- @string name The name of the table to add
-- @tparam table tbl The table to add
function Payload:add_table(name, tbl)
  if self.encode_base64 then
    self:add(name, base64.encode(json.encode(tbl)))
  else
    self:add(name, json.encode(tbl))
  end
end

--- Gets the payload table
-- @treturn table The payload table
function Payload:get()
  return self.nv_pairs
end

--- Builds the appropriate payload
-- @string request_method The request method that will determine the payload type ("POST" or "GET")
-- @treturn string The built payload
function Payload:build(request_method)
  if request_method == "POST" then
    return build_json(self:get())
  else
    return build_querystring(self:get())
  end
end

--- Creates a new Payload object
-- @bool encode_base64 Whether to base64 encode the payload
-- @treturn Payload The new Payload Builder instance
function payload.new_payload_builder(encode_base64)
  validate.is_boolean("encode_base64", encode_base64)
  local p = {
    nv_pairs = {},
    encode_base64 = encode_base64,
  }
  setmetatable(p, { __index = Payload })
  return p
end

-- --------------------------------------------------------------

return payload
