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
local function initTracker(uri)
	local tracker = tracker.newTracker(uri, config)
	return tracker
end

-- Helper to generate the collector url from a collector host name.
-- Example: as_collector_url("snplow.myshop.com") => "http://snplow.myshop.com/i"
-- @param host string: The host name of the collector
-- @return string: The full collector URI
local function asCollectorUri(host)
	return "http://" .. host .. "/i"
end

-- Helper to generate the collector url from a CloudFront distribution subdomain.
-- Example: collectorUriFromCf("f3f77d9def5") => "http://f3f77d9def5.cloudfront.net/i"
-- @param cfSubdomain string The CloudFront subdomain on which the collector's distribution is hosted
-- @return string: The full collector URI
local function collectorUriFromCf(cfSubdomain)
	return asCollectorUri(cfSubdomain .. ".cloudfront.net")
end

-- --------------------------------------------------------------
-- Factories to create a tracker

-- Create a new Snowplow tracker talking to a URI-based collector on the given host.
-- @param host string: The host (i.e. full domain) on which the collector is running
-- @return tracker table: The new tracker
function snowplow.newTrackerForUri(host)
	validate.isNonEmptyString("host", host)
	local uri = asCollectorUri(host)
	return initTracker(uri)
end

-- Create a new Snowplow tracker talking to a CloudFront-based collector on the given subdomain.
-- @param cfSubdomain string: The CloudFront subdomain on which the collector is running
-- @return tracker table: The new tracker
function snowplow.newTrackerForCf(cfSubdomain)
	validate.isNonEmptyString("cfSubdomain", cfSubdomain)
	local uri = collectorUriFromCf(cfSubdomain)
	return initTracker(uri)
end

-- --------------------------------------------------------------

return snowplow
