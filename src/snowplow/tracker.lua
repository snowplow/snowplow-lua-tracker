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
local ss = require("lib.utils").safe_string -- Alias

local tracker = {} -- The module
local Tracker = {} -- The class
Tracker.__index = Tracker

-- --------------------------------------------------------------
-- Constants & config

local VERSION = "lua-0.1.0-1"
local DEFAULT_ENCODE_BASE64 = true
local DEFAULT_PLATFORM = "pc"
local SUPPORTED_PLATFORMS = set.new_set({ "pc", "tv", "mob", "cnsl", "iot" })

-- --------------------------------------------------------------
-- Factory to create a new Tracker

-- Creates a new tracker.
-- @param collector_uri string: the full URI to the Snowplow collector
-- @return table: The new tracker
function tracker.new_tracker(collector_uri)
  local trck = {}
  setmetatable(trck, Tracker)
  trck.collector_uri = collector_uri
  trck.config = {
    encode_base64 = DEFAULT_ENCODE_BASE64,
    platform = DEFAULT_PLATFORM,
    version = VERSION,
  }

  return trck
end

-- --------------------------------------------------------------
-- Private static methods

-- Generates a moderately-unique six-digit transaction ID - essentially a nonce to make sure this event isn't
-- recorded twice.
-- @return string: The transaction ID
local function get_transaction_id()
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
local function get_timestamp(tstamp)
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
local function http_get(uri)
  -- `resp` is the table `:getinfo` reads from
  local resp = {}
  local c = curl.easy({
    url = uri,
  }):setopt_writefunction(table.insert, resp)
  local _, err = pcall(function()
    c:perform()
  end)
  local status_code = c:getinfo(curl.INFO_RESPONSE_CODE)

  if err ~= nil then
    return false, "Host [" .. uri .. "] not found (possible connectivity error)"
  else
    local code = tonumber(status_code)
    if code == nil or code ~= math.floor(code) or code < 0 or code >= 600 then
      return false, "Unrecognised status code [" .. ss(status_code) .. "]"
    elseif code >= 400 and code < 500 then
      return false, "HTTP status code [" .. ss(status_code) .. "] is a client error"
    elseif code >= 500 then
      return false, "HTTP status code [" .. ss(status_code) .. "] is a server error"
    end
  end

  return true
end

-- --------------------------------------------------------------
-- Private methods

-- Tracks any given SnowPlow event, by sending the specific event_pairs to the SnowPlow collector.
-- @param: self table: The Tracker instance
-- @param pb table: A partially populated payload_builder closure. We will finish populating it in this method, then
-- build() it
-- @return boolean, string: Whether event was successfully collected; and the reason for failure if not
local function track(self, pb)
  -- Add the standard name-value pairs
  pb.add("p", self.config.platform)
  pb.add_raw("tv", self.config.version)
  pb.add("tid", get_transaction_id())

  -- Add the fields which may have been set
  pb.add("uid", self.user_id)
  pb.add("aid", self.app_id)
  pb.add_raw("res", self.screen_resolution)
  pb.add_raw("vp", self.viewport)
  pb.add_raw("cd", self.color_depth)

  -- Now build the payload_builder
  local uri = self.collector_uri .. pb.build()

  -- For mocking
  if _TEST then
    self._http_get(uri)
  end

  -- Finally send to Snowplow
  return http_get(uri)
end

-- --------------------------------------------------------------
-- Configuration methods

-- Configuration setting: whether to Base64-encode the properties of unstructured events and custom variables.
-- Encoding means a circa~25% space saving.
-- Defaults to true.
-- @param encode boolean: whether to base64-encode or not
function Tracker:encode_base64(encode)
  validate.is_boolean("encode", encode)
  self.config.encode_base64 = encode
end

-- The default platform for Lua is "pc". If you are using Lua on another platform,
-- (e.g. as part of a console videogame), you can change the platform here.
-- For details on the different platforms, see:
-- https://github.com/snowplow/snowplow/wiki/SnowPlow-Tracker-Protocol#wiki-appid
-- @param platform string: The short-form name of the platform to set. Can be "pc", "tv", "mob", "csl" or "iot".
function Tracker:platform(platform)
  validate.is_string_from_set(SUPPORTED_PLATFORMS, "platform", platform)
  self.config.platform = platform
end

-- --------------------------------------------------------------
-- Data setters

-- Sets the application ID to record against each event.
-- @param app_id string: The application ID to set
function Tracker:set_app_id(app_id)
  validate.is_non_empty_string("app_id", app_id)
  self.app_id = app_id
end

-- Sets the business user ID.
-- @param user_id string The business user ID to set.
function Tracker:set_user_id(user_id)
  validate.is_non_empty_string("user_id", user_id)
  self.user_id = user_id
end

-- If you have access to a graphics library which can tell you screen width and height, then set it here.
-- @param width number: The screen width
-- @param height number: The screen height
function Tracker:set_screen_resolution(width, height)
  validate.is_positive_integer("width", width)
  validate.is_positive_integer("height", height)
  self.screen_resolution = width .. "x" .. height
end

-- If you have access to a graphics library which can tell you the width and height of the viewport (i.e.
-- the screen space taken up by this app), then set it here.
-- @param width number: The viewport width
-- @param height number: The viewport height as a number
function Tracker:set_viewport(width, height)
  validate.is_positive_integer("width", width)
  validate.is_positive_integer("height", height)
  self.viewport = width .. "x" .. height
end

-- If you have access to a graphics library which can tell you screen width and height, then set it here.
-- @param depth number: The color depth on this computer
function Tracker:set_color_depth(depth)
  validate.is_positive_integer("depth", depth)
  self.color_depth = depth
end

-- --------------------------------------------------------------
-- Track methods

-- Sends a screen view event to SnowPlow. A screen view must have a `name` and can have an optional `id`.
-- @param name string: Human-readable name for this screen (e.g. "HUD > Save Game").
-- @param id string: Optional unique identifier for this screen. Could be e.g. a GUID or identifier from a game CMS
-- @param tstamp number: Optional time (in seconds since epoch) at which event occurred
-- @return boolean: whether event was successfully collected; and the reason for failure if not
function Tracker:track_screen_view(name, id, tstamp)
  local pb = payload.new_payload_builder(self.config.encode_base64)
  pb.add_raw("e", "sv")
  pb.add("sv_na", name, validate.is_non_empty_string)
  pb.add("sv_id", id, validate.is_string_or_nil)
  pb.add("dtm", get_timestamp(tstamp), validate.is_positive_integer)

  return track(self, pb)
end

-- Sends a custom structured event to SnowPlow.
-- @param category string: The name you supply for the group of objects you want to track
-- @param action string: A string that is uniquely paired with each category e.g. the type of user interaction for
-- the object
-- @param label string: An optional string to provide additional dimensions to the event data
-- @param property string: An optional string describing the objector the action performed on it.
-- @param value string: A value that you can use to provide numerical data about the user event
-- @param tstamp number: Optional time (in seconds since epoch) at which event occurred
-- @return boolean whether event was successfully collected; and the reason for failure if not
function Tracker:track_struct_event(category, action, label, property, value, tstamp)
  local pb = payload.new_payload_builder(self.config.encode_base64)
  pb.add_raw("e", "se")
  pb.add("se_ca", category, validate.is_non_empty_string)
  pb.add("se_ac", action, validate.is_non_empty_string)
  pb.add("se_la", label, validate.is_string_or_nil)
  pb.add("se_pr", property, validate.is_string_or_nil)
  pb.add("se_va", value, validate.is_number_or_nil)
  pb.add("dtm", get_timestamp(tstamp), validate.is_positive_integer)

  return track(self, pb)
end

-- Sends a custom unstructured event to Snowplow.
-- @param name string: The name of the event
-- @param properties string: The properties of the event
-- @param tstamp number: Optional time (in seconds since epoch) at which event occurred
-- @return: boolean whether event was successfully collected; and the reason for failure if not
function Tracker:track_unstruct_event(name, properties, tstamp)
  local pb = payload.new_payload_builder(self.config.encode_base64)
  pb.add_raw("e", "ue")
  pb.add("ue_na", name, validate.is_non_empty_string)
  pb.add_props("ue_px", "ue_pr", properties, validate.is_non_empty_table)
  pb.add("dtm", get_timestamp(tstamp), validate.is_positive_integer)

  return track(self, pb)
end

-- --------------------------------------------------------------
-- Mocks

if _TEST then
  -- A mock on the table to be checked by Busted. Does nothing - we will simply inspect the uri argument.
  function Tracker._http_get(uri) end -- luacheck: ignore
end

-- --------------------------------------------------------------

return tracker
