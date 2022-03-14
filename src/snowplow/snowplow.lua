--- snowplow.lua
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

local validate = require("validate")
local tracker = require("tracker")
local set = require("lib.set")

local snowplow = {}
local VALID_PROTOCOLS = set.new_set({ "http", "https" })

-- --------------------------------------------------------------
-- Static methods

-- Helper to generate the collector url from a given url.
-- Example: as_collector_url("snplow.myshop.com") => "https://snplow.myshop.com/i"
-- @param url string: The url of the collector
-- @return string: The full collector URL
local function as_collector_url(url)
  if url:find("://") then
    local _, _, protocol = url:find("^(%a[^:]*)")
    validate.is_string_from_set(VALID_PROTOCOLS, "protocol", protocol)
    return url .. "/i"
  end

  return "https://" .. url .. "/i"
end

-- Builds our new tracker using the supplied URL.
-- @param url string: The full url to the Snowplow collector
-- @return tracker table: The new tracker
function snowplow.new_tracker(url)
  validate.is_non_empty_string("url", url)
  local collector_url = as_collector_url(url)
  return tracker.new_tracker(collector_url)
end

-- --------------------------------------------------------------

return snowplow
