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

local snowplow = {}

-- --------------------------------------------------------------
-- Static methods

-- Builds our new tracker using the supplied URI.
-- @param uri string: The full URI to the Snowplow collector
-- @return tracker table: The new tracker
local function init_tracker(uri)
  local tracker = tracker.new_tracker(uri, config)
  return tracker
end

-- Helper to generate the collector url from a collector host name.
-- Example: as_collector_url("snplow.myshop.com") => "http://snplow.myshop.com/i"
-- @param host string: The host name of the collector
-- @return string: The full collector URI
local function as_collector_uri(host)
  return "http://" .. host .. "/i"
end

-- Helper to generate the collector url from a CloudFront distribution subdomain.
-- Example: collector_uri_from_cf("f3f77d9def5") => "http://f3f77d9def5.cloudfront.net/i"
-- @param cf_subdomain string The CloudFront subdomain on which the collector's distribution is hosted
-- @return string: The full collector URI
local function collector_uri_from_cf(cf_subdomain)
  return as_collector_uri(cf_subdomain .. ".cloudfront.net")
end

-- --------------------------------------------------------------
-- Factories to create a tracker

-- Create a new Snowplow tracker talking to a URI-based collector on the given host.
-- @param host string: The host (i.e. full domain) on which the collector is running
-- @return tracker table: The new tracker
function snowplow.new_tracker_for_uri(host)
  validate.is_non_empty_string("host", host)
  local uri = as_collector_uri(host)
  return init_tracker(uri)
end

-- Create a new Snowplow tracker talking to a CloudFront-based collector on the given subdomain.
-- @param cf_subdomain string: The CloudFront subdomain on which the collector is running
-- @return tracker table: The new tracker
function snowplow.new_tracker_for_cf(cf_subdomain)
  validate.is_non_empty_string("cf_subdomain", cf_subdomain)
  local uri = collector_uri_from_cf(cf_subdomain)
  return init_tracker(uri)
end

-- --------------------------------------------------------------

return snowplow
