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

local curl = require("curl")
local validate = require("validate")
local payload = require("payload")
local set = require("lib.set")
local ss = require("lib.utils").safeString -- Alias

local tracker = {} -- The module
local Tracker = {} -- The class
Tracker.__index = Tracker

-- --------------------------------------------------------------
-- Constants & config

local VERSION = "lua-0.1.0-1"
local DEFAULT_ENCODE_BASE64 = true
local DEFAULT_PLATFORM = "pc"
local SUPPORTED_PLATFORMS = set.newSet({ "pc", "tv", "mob", "cnsl", "iot" })

-- --------------------------------------------------------------
-- Factory to create a new Tracker

-- Creates a new tracker.
-- @param collectorUri string: the full URI to the Snowplow collector
-- @return table: The new tracker
function tracker.newTracker(collectorUri)
  local trck = {}
  setmetatable(trck, Tracker)
  trck.collectorUri = collectorUri
  trck.config = {
    encodeBase64 = DEFAULT_ENCODE_BASE64,
    platform = DEFAULT_PLATFORM,
    version = VERSION,
  }

  return trck
end

-- --------------------------------------------------------------
-- Private static methods

-- Generates a moderately-unique six-digit transaction ID - essentially a nonce to make sure this event isn't recorded twice.
-- @return string: The transaction ID
function getTransactionId()
  local tid
  math.randomseed(os.time())
  local rand = math.random(100000, 999999)
  tid = tostring(rand)

  -- To handle testing
  -- TODO: is there a cleaner way of doing this? DI or a mock or something?
  if _TEST then
    tid = "100000"
  end

  return tid
end

-- Gets the current timestamp as total milliseconds since epoch.
-- @param tstamp number: Optional time (in seconds since epoch) at which event occurred
-- @return number: The timestamp
function getTimestamp(tstamp)
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

-- GETs the given URI: this is how our event data is transmitted to the Snowplow collector.
-- @param uri string: The URI (including querystring) to GET
-- @return boolean, string: Whether event was successfully collected; and the reason for failure if not
function httpGet(uri)
  -- `resp` is the table `:getinfo` reads from
  local resp = {}
  local c = curl.easy({
    url = uri,
  }):setopt_writefunction(table.insert, resp)
  local _, err = pcall(function()
    c:perform()
  end)
  local statusCode = c:getinfo(curl.INFO_RESPONSE_CODE)

  if err ~= nil then
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

-- Tracks any given SnowPlow event, by sending the specific event_pairs to the SnowPlow collector.
-- @param: self table: The Tracker instance
-- @param pb table: A partially populated payloadBuilder closure. We will finish populating it in this method, then build() it
-- @return boolean, string: Whether event was successfully collected; and the reason for failure if not
function track(self, pb)
  -- Add the standard name-value pairs
  pb.add("p", self.config.platform)
  pb.addRaw("tv", self.config.version)
  pb.add("tid", getTransactionId())

  -- Add the fields which may have been set
  pb.add("uid", self.userId)
  pb.add("aid", self.appId)
  pb.addRaw("res", self.screenResolution)
  pb.addRaw("vp", self.viewport)
  pb.addRaw("cd", self.colorDepth)

  -- Now build the payloadBuilder
  local uri = self.collectorUri .. pb.build()

  -- For mocking
  if _TEST then
    self._httpGet(uri)
  end

  -- Finally send to Snowplow
  return httpGet(uri)
end

-- --------------------------------------------------------------
-- Configuration methods

-- Configuration setting: whether to Base64-encode the properties of unstructured events and custom variables.
-- Encoding means a circa~25% space saving.
-- Defaults to true.
-- @param encode boolean: whether to base64-encode or not
function Tracker:encodeBase64(encode)
  validate.isBoolean("encode", encode)
  self.config.encodeBase64 = encode
end

-- The default platform for Lua is "pc". If you are using Lua on another platform,
-- (e.g. as part of a console videogame), you can change the platform here.
-- For details on the different platforms, see:
-- https://github.com/snowplow/snowplow/wiki/SnowPlow-Tracker-Protocol#wiki-appid
-- @param platform string: The short-form name of the platform to set. Can be "pc", "tv", "mob", "csl" or "iot".
function Tracker:platform(platform)
  validate.isStringFromSet(SUPPORTED_PLATFORMS, "platform", platform)
  self.config.platform = platform
end

-- --------------------------------------------------------------
-- Data setters

-- Sets the application ID to record against each event.
-- @param appId string: The application ID to set
function Tracker:setAppId(appId)
  validate.isNonEmptyString("appId", appId)
  self.appId = appId
end

-- Sets the business user ID.
-- @param userId string The business user ID to set.
function Tracker:setUserId(userId)
  validate.isNonEmptyString("userId", userId)
  self.userId = userId
end

-- If you have access to a graphics library which can tell you screen width and height, then set it here.
-- @param width number: The screen width
-- @param height number: The screen height
function Tracker:setScreenResolution(width, height)
  validate.isPositiveInteger("width", width)
  validate.isPositiveInteger("height", height)
  self.screenResolution = width .. "x" .. height
end

-- If you have access to a graphics library which can tell you the width and height of the viewport (i.e.
-- the screen space taken up by this app), then set it here.
-- @param width number: The viewport width
-- @param height number: The viewport height as a number
function Tracker:setViewport(width, height)
  validate.isPositiveInteger("width", width)
  validate.isPositiveInteger("height", height)
  self.viewport = width .. "x" .. height
end

-- If you have access to a graphics library which can tell you screen width and height, then set it here.
-- @param depth number: The color depth on this computer
function Tracker:setColorDepth(depth)
  validate.isPositiveInteger("depth", depth)
  self.colorDepth = depth
end

-- --------------------------------------------------------------
-- Track methods

-- Sends a screen view event to SnowPlow. A screen view must have a `name` and can have an optional `id`.
-- @param name string: Human-readable name for this screen (e.g. "HUD > Save Game").
-- @param id string: Optional unique identifier for this screen. Could be e.g. a GUID or identifier from a game CMS
-- @param tstamp number: Optional time (in seconds since epoch) at which event occurred
-- @return boolean: whether event was successfully collected; and the reason for failure if not
function Tracker:trackScreenView(name, id, tstamp)
  local pb = payload.newPayloadBuilder(self.config.encodeBase64)
  pb.addRaw("e", "sv")
  pb.add("sv_na", name, validate.isNonEmptyString)
  pb.add("sv_id", id, validate.isStringOrNil)
  pb.add("dtm", getTimestamp(tstamp), validate.isPositiveInteger)

  return track(self, pb)
end

-- Sends a custom structured event to SnowPlow.
-- @param category string: The name you supply for the group of objects you want to track
-- @param action string: A string that is uniquely paired with each category e.g. the type of user interaction for the object
-- @param label string: An optional string to provide additional dimensions to the event data
-- @param property string: An optional string describing the objector the action performed on it.
-- @param value string: A value that you can use to provide numerical data about the user event
-- @param tstamp number: Optional time (in seconds since epoch) at which event occurred
-- @return boolean whether event was successfully collected; and the reason for failure if not
function Tracker:trackStructEvent(category, action, label, property, value, tstamp)
  local pb = payload.newPayloadBuilder(self.config.encodeBase64)
  pb.addRaw("e", "se")
  pb.add("se_ca", category, validate.isNonEmptyString)
  pb.add("se_ac", action, validate.isNonEmptyString)
  pb.add("se_la", label, validate.isStringOrNil)
  pb.add("se_pr", property, validate.isStringOrNil)
  pb.add("se_va", value, validate.isNumberOrNil)
  pb.add("dtm", getTimestamp(tstamp), validate.isPositiveInteger)

  return track(self, pb)
end

-- Sends a custom unstructured event to Snowplow.
-- @param name string: The name of the event
-- @param properties string: The properties of the event
-- @param tstamp number: Optional time (in seconds since epoch) at which event occurred
-- @return: boolean whether event was successfully collected; and the reason for failure if not
function Tracker:trackUnstructEvent(name, properties, tstamp)
  local pb = payload.newPayloadBuilder(self.config.encodeBase64)
  pb.addRaw("e", "ue")
  pb.add("ue_na", name, validate.isNonEmptyString)
  pb.addProps("ue_px", "ue_pr", properties, validate.isNonEmptyTable)
  pb.add("dtm", getTimestamp(tstamp), validate.isPositiveInteger)

  return track(self, pb)
end

-- --------------------------------------------------------------
-- Mocks

if _TEST then
  -- A mock on the table to be checked by Busted. Does nothing - we will simply inspect the uri argument.
  function Tracker._httpGet(uri) end
end

-- --------------------------------------------------------------

return tracker
