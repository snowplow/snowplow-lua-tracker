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

local validate = require( "validate" )

local snowplow = {}

-- --------------------------------------------------------------
-- Constants & config

local config = {
  encodeBase64 = true,
  platform     = "pc",
  version      = "lua-0.1.0"
}

-- --------------------------------------------------------------
-- Static methods

local function newTracker(uri)
  --[[--
  Builds our new tracker using the supplied URI.

  @Parameter: uri
    The full URI to the Snowplow collector
  --]]--

  -- Create a new tracker
  local tracker = require("tracker")

  -- Add these to our tracker
  tracker.collectorUri = uri
  tracker.config = config

  -- Return the fully populated tracker
  return tracker
end

local function asCollectorUri(host)
  --[[--
  Helper to generate the collector url from a
  collector host name.

  Example:
  as_collector_url("snplow.myshop.com") => "http://snplow.myshop.com/i"
  --]]--

  return "http://" .. host .. "/i"
end

local function collectorUriFromCf(cfSubdomain)
  --[[--
  Helper to generate the collector url from a
  CloudFront distribution subdomain.

  Example:
  collectorUriFromCf("f3f77d9def5") => "http://f3f77d9def5.cloudfront.net/i"

  @Parameter: cfSubdomain
    The CloudFront subdomain on which the collector's
    distribution is hosted
  --]]--

  return asCollectorUri( cfSubdomain .. ".cloudfront.net" )
end

-- --------------------------------------------------------------
-- Factories to create a tracker

snowplow.newTrackerForUri = function (host)
  --[[--
  Create a new Snowplow tracker talking to a
  URI-based collector on the given host.

  @Parameter: host
    The host (i.e. full domain) on which the
    collector is running
  --]]--

  validate.isNonEmptyString( "host", host )
  local uri = asCollectorUri( host )
  return newTracker( uri )
end

snowplow.newTrackerForCf = function (cfSubdomain)
  --[[--
  Create a new Snowplow tracker talking to a
  CloudFront-based collector on the given subdomain.

  @Parameter: host
    The CloudFront subdomain on which the
    collector is running
  --]]--

  validate.isNonEmptyString( "cfSubdomain", cfSubdomain )
  local uri = collectorUriFromCf( cfSubdomain )
  return newTracker( uri )
end

-- --------------------------------------------------------------

return snowplow