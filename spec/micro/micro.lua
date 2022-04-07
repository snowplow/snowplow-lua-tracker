--- micro.lua
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
local json = require("lunajson")

-- Get the URL for micro
-- @return string: The $MICRO_URL env var, or default if not set
local function get_url()
  return os.getenv("MICRO_URL") or "http://localhost:9090"
end

-- Clear micro's cache
local function clear_cache()
  local c = curl.easy({
    url = get_url() .. "/micro/reset",
  })
  -- We don't want to print the response body
  c:setopt_writefunction(function() end)

  c:perform()
end

-- Get good events from micro
-- @param filter_table table: A optional table of filters to apply to the events
-- @return table: A table of events
local function get_good_events(filter_table)
  local url = get_url() .. "/micro/good"
  local resp = {}
  local c = curl.easy({
    url = url,
  }):setopt_writefunction(table.insert, resp)

  if filter_table then
    c:setopt_post(true)
    c:setopt_httpheader({
      "Content-Type: application/json; charset=utf-8",
    })
    c:setopt_postfields(json.encode(filter_table))
  end

  c:perform()
  -- Data gets written in chunks to resp, so we need to concat it
  return json.decode(table.concat(resp))
end

return {
  get_url = get_url,
  clear_cache = clear_cache,
  get_good_events = get_good_events,
}
