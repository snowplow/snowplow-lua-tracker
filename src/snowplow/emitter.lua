--- emitter.lua
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
--
-- Authors:     Greg Leonard
-- Copyright:   Copyright (c) 2022 Snowplow Analytics Ltd
-- License:     Apache License Version 2.0

local curl = require("cURL")
local ss = require("lib.utils").safe_string -- Alias
local set = require("lib.set")
local validate = require("validate")

local Emitter = {}
local emitter = {}

local VALID_PROTOCOLS = set.new_set({ "http", "https" })

-- --------------------------------------------------------------
-- Private methods

-- Helper to generate the collector url from a given url.
-- @param url string: The url of the collector
-- @return string: The full collector URL
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

-- Decides if a given status code is considered a success.
-- @param status_code number: The HTTP status code
-- @return boolean, string: Whether event was successfully collected; and the reason for failure if not
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

-- Performs a GET request with a given payload to the collector.
-- @param uri string: The URI (including querystring) to GET
-- @return boolean, string: Whether event was successfully collected; and the reason for failure if not
local function _get(self, payload)
  local url = self.collector_url .. payload
  -- `resp` is the table `:getinfo` reads from
  local resp = {}
  local c = curl.easy({
    url = url,
  }):setopt_writefunction(table.insert, resp)

  local _, err = pcall(function()
    c:perform()
  end)

  if err ~= nil then
    return false, "Host [" .. self.collector_url .. payload .. "] not found (possible connectivity error)"
  end

  return handle_status_code(c:getinfo(curl.INFO_RESPONSE_CODE))
end

-- Performs a POST request with a given payload to the collector.
-- @param uri string: The URI (including querystring) to GET
-- @param method string: The HTTP method to use
-- @return boolean, string: Whether event was successfully collected; and the reason for failure if not
local function _post(self, payload)
  -- `resp` is the table `:getinfo` reads from
  local resp = {}
  local c = curl.easy({
    url = self.collector_url,
    post = true,
    httpheader = {
      "Content-Type: application/json; charset=utf-8",
    },
    postfields = payload,
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

-- Returns the request method
-- @return string: The request method
function Emitter:get_request_method()
  return self.request_method
end

-- Returns the collector url
-- @return string: The collector url
function Emitter:get_collector_url()
  return self.collector_url
end

-- Sends a payload to the collector
-- @param payload string: The payload to send
-- @return boolean, string: Whether event was successfully collected; and the reason for failure if not
function Emitter:send(payload)
  return self.request_func(self, payload)
end

-- Builds a new emitter instance
-- @param collector_url string: The url of the collector
-- @param request_method string: The request method to use
-- @return Emitter: The new emitter instance
function emitter.new(collector_url, request_method)
  local e = {}
  setmetatable(e, { __index = Emitter })

  -- The HTTP method to use if request_method is present
  -- otherwise, POST is used
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
