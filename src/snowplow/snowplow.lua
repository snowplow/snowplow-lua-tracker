-- snowplow.lua
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

--- The main Snowplow module.
-- @module Snowplow
-- @author Alex Dean
-- @copyright Copyright (c) 2013 Snowplow Analytics Ltd
-- @license Apache License Version 2.0

local validate = require("validate")
local tracker = require("tracker")
local emitter = require("emitter")
local set = require("lib.set")

local snowplow = {}
local VALID_REQUEST_TYPES = set.new_set({ "GET", "POST" })

--- Creates a tracker instance.
-- @string url The url to the Snowplow collector
-- @string[opt="POST"] request_type The request type to use ("GET" or "POST")
-- @bool[opt=true] encode_base64 Whether to base64 encode the payloads
-- @treturn Tracker The new tracker
function snowplow.new_tracker(url, request_type, encode_base64)
  validate.is_non_empty_string("url", url)

  if request_type ~= nil then
    validate.is_string_from_set(VALID_REQUEST_TYPES, "VALID_REQUEST_TYPES", request_type)
  end
  request_type = request_type or "POST"

  local tracker_emitter = emitter.new(url, request_type)
  return tracker.new_tracker(tracker_emitter, encode_base64)
end

-- --------------------------------------------------------------

return snowplow
