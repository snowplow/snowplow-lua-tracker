--- tracker.lua
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

local http     = require( "socket.http" )
local validate = require( "validate" )
local payload  = require( "payload" )
local set      = require( "lib.set" )
local ss       = require( "lib.utils" ).safeString -- Alias

local tracker = {} -- The module
local Tracker = {} -- The class
Tracker.__index = Tracker

-- --------------------------------------------------------------
-- Constants & config

local VERSION = "lua-0.1.0-1"
local DEFAULT_ENCODE_BASE64 = true
local DEFAULT_PLATFORM = "pc"
local SUPPORTED_PLATFORMS = set.newSet { "pc", "tv", "mob", "cnsl", "iot" }
local HTTP_ERRORS = set.newSet { "host not found",
                                 "No address associated with name",
                                 "No address associated with hostname"
                               }

-- --------------------------------------------------------------
-- Factory to create a new Tracker

function tracker.newTracker(collectorUri)
  --[[--
  Creates a new tracker.

  @Parameter: collectorUri
    String: the full URI to the Snowplow collector
  --]]--

  local trck = {}
  setmetatable( trck, Tracker )
  trck.collectorUri = collectorUri
  trck.config = {
    encodeBase64 = DEFAULT_ENCODE_BASE64,
    platform     = DEFAULT_PLATFORM,
    version      = VERSION
  }

  return trck
end

-- --------------------------------------------------------------
-- Private static methods

function getTransactionId()
  --[[--
  Generates a moderately-unique six-digit transaction ID
  - essentially a nonce to make sure this event isn't
  recorded twice.
  --]]--

  local tid
  math.randomseed( os.time() )
  local rand = math.random(100000, 999999)
  tid = tostring( rand )

  -- To handle testing
  -- TODO: is there a cleaner way of doing this? DI or a mock or something?
  if _TEST then
    tid = "100000"
  end

  return tid
end

function getTimestamp( tstamp )
  --[[--
  Returns the current timestamp as total milliseconds
  since epoch.

  @Parameter: tstamp
    Optional time (in seconds since epoch) at which
    event occurred
  --]]--

  local timestamp
  if tstamp == nil then
    timestamp = os.time()
  elseif type(tstamp) == "number" then
    timestamp = tstamp * 1000
  else
    timestamp = tstamp -- Hope the calling code deals with the error
  end

  return timestamp
end

function httpGet(uri)
  --[[--
  GETs the given URI: this is how our event data
  is transmitted to the Snowplow collector.

  @Parameter: uri
    The URI (including querystring) to GET

  @Return: true/false for whether event was successfully collected; if false, the error message
  --]]--

  result, statusCode, content = http.request( uri )

  if HTTP_ERRORS:contains(statusCode) then
    return false, "Host [" .. uri .. "] not found (possible connectivity error)"
  else
    local code = tonumber(statusCode)
    if code == nil or code ~= math.floor(code) or code < 0 or code >= 600 then
      return false, "Unrecognised status code [" .. ss(statusCode) .. "]"
    elseif code >= 400 and code < 500 then
      return false, "HTTP status code [" .. ss(statusCode) .. "] is a client error"
    elseif code >= 500 then
      return false, "HTTP status code [" .. ss(statusCode) .. "] is a server error"
    end
  end

  return true
end

-- --------------------------------------------------------------
-- Private methods

function track(self, pb)
  --[[--
  Tracks any given SnowPlow event, by sending the specific
  event_pairs to the SnowPlow collector.

  @Parameter: self
    The Tracker table holding our configuration etc

  @Parameter: pb
    A partially populated payloadBuilder closure. We will
    finish populating it in this method, then build() it

  @Return: true/false for whether event was successfully collected; if false, the error message
  --]]--

  -- Add the standard name-value pairs
  pb.add( "p",  self.config.platform )
  pb.addRaw( "tv", self.config.version )
  pb.add( "tid", getTransactionId() )

  -- Add the fields which may have been set
  pb.add( "uid", self.userId )
  pb.add( "aid", self.appId )
  pb.addRaw( "res", self.screenResolution )
  pb.addRaw( "vp",  self.viewport )
  pb.addRaw( "cd",  self.colorDepth )

  -- Now build the payloadBuilder
  local uri = self.collectorUri .. pb.build()

  -- For mocking
  if _TEST then
    self._httpGet( uri )
  end

  -- Finally send to Snowplow
  return httpGet( uri )
end

-- --------------------------------------------------------------
-- Configuration methods

function Tracker:encodeBase64(encode)
  --[[--
  Configuration setting: whether to Base64-encode the
  properties of unstructured events and custom
  variables.
  Encoding means a circa~25% space saving.

  Defaults to true.

  @Parameter: encode
    Boolean: whether to base64-encode or not
  --]]--

  validate.isBoolean( "encode", encode )
  self.config.encodeBase64 = encode
end

function Tracker:platform(platform)
  --[[--
  The default platform for Lua is "pc". If you are using Lua on
  another platform (e.g. as part of a console videogame), you
  can change the platform here.

  For details on the different platforms, see:
  https://github.com/snowplow/snowplow/wiki/SnowPlow-Tracker-Protocol#wiki-appid

  @Parameter: platform
    The short-form name of the platform to set. Can be "pc",
    "tv", "mob", "csl" or "iot".
  --]]--

  validate.isStringFromSet( SUPPORTED_PLATFORMS, "platform", platform )
  self.config.platform = platform
end

-- --------------------------------------------------------------
-- Data setters

function Tracker:setAppId(appId)
  --[[--
  Sets the application ID to record against
  each event.

  @Parameter: appId
    The application ID to set
  --]]--

  validate.isNonEmptyString( "appId", appId )
  self.appId = appId
end

function Tracker:setUserId(userId)
  --[[--
  Sets the business user ID.

  @Parameter; userId
    The business user ID to set.
  --]]--

  validate.isNonEmptyString( "userId", userId )
  self.userId = userId
end

function Tracker:setScreenResolution(width, height)
  --[[--
  If you have access to a graphics library which can
  tell you screen width and height, then set it here.

  @Parameter: width
    The screen width as a number
  @Parameter: height
    The screen height as a number
  --]]--

  validate.isPositiveInteger( "width", width )
  validate.isPositiveInteger( "height", height )
  self.screenResolution = width .. "x" .. height
end

function Tracker:setViewport(width, height)
  --[[--
  If you have access to a graphics library which can
  tell you the width and height of the viewport (i.e.
  the screen space taken up by this app), then set it
  here.

  @Parameter: width
    The viewport width as a number
  @Parameter: height
    The viewport height as a number
  --]]--

  validate.isPositiveInteger( "width", width )
  validate.isPositiveInteger( "height", height )
  self.viewport = width .. "x" .. height
end

function Tracker:setColorDepth(depth)
  --[[--
  If you have access to a graphics library which can
  tell you screen width and height, then set it here.
  
  @Parameter: depth
    The color depth on this computer
  --]]--

  validate.isPositiveInteger( "depth", depth )
  self.colorDepth = depth
end

-- --------------------------------------------------------------
-- Track methods

function Tracker:trackScreenView(name, id, tstamp)
  --[[--
  Sends a screen view event to SnowPlow. A screen view
  must have a `name` and can have an optional `id`.

  @Parameter: name
    Human-readable name for this screen (e.g.
    "HUD > Save Game"). String
  @Parameter: id
    Optional unique identifier for this screen. Could be e.g.
    a GUID or identifier from a game CMS. String
  @Parameter: tstamp
    Optional time (in seconds since epoch) at which event
    occurred

  @Return: true/false for whether event was successfully collected; if false, the error message
  --]]--

  local pb = payload.newPayloadBuilder( self.config.encodeBase64 )
  pb.addRaw( "e", "sv" )
  pb.add( "sv_na", name, validate.isNonEmptyString )
  pb.add( "sv_id", id, validate.isStringOrNil )
  pb.add( "dtm", getTimestamp( tstamp ), validate.isPositiveInteger )

  return track( self, pb )
end

function Tracker:trackStructEvent(category, action, label, property, value, tstamp)
  --[[--
  Sends a custom structured event to SnowPlow.

  @Parameter: category
    The name you supply for the group of
    objects you want to track
  @Parameter: action
    A string that is uniquely paired with each
    category, and commonly used to define the
    type of user interaction for the object
  @Parameter: label
    An optional string to provide additional
    dimensions to the event data
  @Parameter: property
    An optional string describing the object
    or the action performed on it. This might
    be the quantity of an item added to basket
  @Parameter: value
    A value that you can use to provide
    numerical data about the user event
  @Parameter: tstamp
    Optional time (in seconds since epoch) at which
    event occurred

  @Return: true/false for whether event was successfully collected; if false, the error message
  --]]--

  local pb = payload.newPayloadBuilder( self.config.encodeBase64 )
  pb.addRaw( "e", "se" )
  pb.add( "se_ca", category, validate.isNonEmptyString )
  pb.add( "se_ac", action, validate.isNonEmptyString )
  pb.add( "se_la", label, validate.isStringOrNil )
  pb.add( "se_pr", property, validate.isStringOrNil )
  pb.add( "se_va", value, validate.isNumberOrNil )
  pb.add( "dtm", getTimestamp( tstamp ), validate.isPositiveInteger )

  return track( self, pb )
end

function Tracker:trackUnstructEvent(name, properties, tstamp)
  --[[--
  Sends a custom unstructured event to Snowplow.

  @Parameter: name
    The name of the event
  @Parameter: properties
    The properties of the event
  @Parameter: tstamp
    Optional time (in seconds since epoch) at which
    event occurred

  @Return: true/false for whether event was successfully collected; if false, the error message
  --]]--

  local pb = payload.newPayloadBuilder( self.config.encodeBase64 )
  pb.addRaw("e", "ue")
  pb.add( "ue_na", name, validate.isNonEmptyString )
  pb.addProps( "ue_px", "ue_pr", properties, validate.isNonEmptyTable )
  pb.add( "dtm", getTimestamp( tstamp ), validate.isPositiveInteger )

  return track( self, pb )
end

-- --------------------------------------------------------------
-- Mocks

if _TEST then
  function Tracker._httpGet(uri)
  --[[--
  A mock on the table to be checked by Busted.
  Does nothing - we will simply inspect the uri
  argument.
  --]]--
  end

end

-- --------------------------------------------------------------

return tracker
