-- emitter.lua
--
-- Copyright (c) 2022 Snowplow Analytics Ltd. All rights reserved.
--
-- This program is licensed to you under the Apache License Version 2.0,
-- and you may not use this file except in compliance with the Apache License Version 2.0.
-- You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the Apache License Version 2.0 is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.

--- An 'Emitter' is a class that can be used to send payloads to a Snowplow collector
-- attached to a 'tracker' instance.
-- @module Emitter
-- @author Greg Leonard
-- @copyright Snowplow Analytics Ltd
-- @license Apache License Version 2.0

local curl = require("cURL")
local ss = require("lib.utils").safe_string -- Alias
local set = require("lib.set")
local validate = require("validate")

--- The Emitter table.
-- @func get_request_method
-- @func get_collector_url
-- @func send
-- @table Emitter

local Emitter = {}
local emitter = {}

local VALID_PROTOCOLS = set.new_set({ "http", "https" })

-- --------------------------------------------------------------
-- Private methods

--- Helper to generate the collector url from a given url.
-- @string url The url of the collector
-- @string request_type The request type
-- @treturn string The full collector URL
local function as_collector_url(url, request_type)
  local path = ({
    ["GET"] = "/i",
    ["POST"] = "/com.snowplowanalytics.snowplow/tp2",
  })[request_type]

  if url:find("://") then
    local _, _, protocol = url:find("^(%a[^:]*)")
    validate.is_string_from_set(VALID_PROTOCOLS, "protocol", protocol)
    return url .. path
  end

  return "https://" .. url .. path
end

--- Decides if a given status code is considered a success.
-- @tparam number status_code The HTTP status code
-- @treturn boolean Whether event was successfully collected
-- @treturn ?string The reason for failure if not
local function handle_status_code(status_code)
  local code = tonumber(status_code)
  if code == nil or code ~= math.floor(code) or code < 0 or code >= 600 then
    return false, "Unrecognised status code [" .. ss(status_code) .. "]"
  elseif code >= 400 and code < 500 then
    return false, "HTTP status code [" .. ss(status_code) .. "] is a client error"
  elseif code >= 500 then
    return false, "HTTP status code [" .. ss(status_code) .. "] is a server error"
  end

  return true
end

--- Performs a GET request with a given payload to the collector.
-- @tparam Emitter self The emitter
-- @tparam Payload payload The payload to send
-- @treturn boolean Whether event was successfully collected
-- @treturn ?string The reason for failure if not
local function _get(self, payload)
  -- `resp` is the table `:getinfo` reads from
  local resp = {}

  -- Add dvce_sent_tstamp
  payload:add("stm", os.time())
  local url = self.collector_url .. payload:build(self.request_method)

  local c = curl.easy({
    url = url,
  }):setopt_writefunction(table.insert, resp)

  local _, err = pcall(function()
    c:perform()
  end)

  if err ~= nil then
    return false, "Host [" .. url .. "] not found (possible connectivity error)"
  end

  return handle_status_code(c:getinfo(curl.INFO_RESPONSE_CODE))
end

--- Performs a POST request with a given payload to the collector.
-- @tparam Emitter self The emitter
-- @tparam Payload payload The payload to send
-- @treturn boolean Whether event was successfully collected
-- @treturn ?string The reason for failure if not
local function _post(self, payload)
  -- `resp` is the table `:getinfo` reads from
  local resp = {}

  -- Add dvce_sent_tstamp
  payload:add("stm", os.time())

  local c = curl.easy({
    url = self.collector_url,
    post = true,
    httpheader = {
      "Content-Type: application/json; charset=utf-8",
    },
    postfields = payload:build(self.request_method),
  }):setopt_writefunction(table.insert, resp)

  local _, err = pcall(function()
    c:perform()
  end)

  if err ~= nil then
    return false, "Host [" .. self.collector_url .. "] not found (possible connectivity error)"
  end

  return handle_status_code(c:getinfo(curl.INFO_RESPONSE_CODE))
end

-- --------------------------------------------------------------
-- Public methods

----
-- @treturn string The Emitter instance request method
function Emitter:get_request_method()
  return self.request_method
end

----
-- @treturn string The Emitter instance collector url
function Emitter:get_collector_url()
  return self.collector_url
end

--- Sends a payload to the collector with the configured request method.
-- @tparam string payload The payload to send
-- @treturn boolean Whether event was successfully collected
-- @treturn ?string The reason for failure if not
function Emitter:send(payload)
  return self.request_func(self, payload)
end

--- Builds a new emitter instance.
-- @string collector_url The url of the collector
-- @string[opt="POST"] request_method The request method to use
-- @treturn Emitter The new emitter instance
function emitter.new(collector_url, request_method)
  local e = {}
  setmetatable(e, { __index = Emitter })

  e.request_method = request_method or "POST"
  e.request_func = ({
    ["GET"] = _get,
    ["POST"] = _post,
  })[e.request_method]

  -- The URI to POST to
  e.collector_url = as_collector_url(collector_url, e.request_method)
  return e
end

return emitter
