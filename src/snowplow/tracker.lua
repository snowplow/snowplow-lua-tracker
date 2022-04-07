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

local validate = require("validate")
local payload = require("payload")
local set = require("lib.set")
local uuid = require("uuid")
local TRACKER_VERSION = require("constants").TRACKER_VERSION

local tracker = {} -- The module
local Tracker = {} -- The class
Tracker.__index = Tracker

-- --------------------------------------------------------------
-- Constants & config

local DEFAULT_ENCODE_BASE64 = true
local DEFAULT_PLATFORM = "pc"
local SUPPORTED_PLATFORMS = set.new_set({ "pc", "tv", "mob", "cnsl", "iot" })

-- --------------------------------------------------------------
-- Factory to create a new Tracker

-- Creates a new tracker.
-- @param emitter table: The emitter to use to send the payloads
-- @param encode_base64 boolean: Whether to base64 encode the payloads
-- @return table: The new tracker
function tracker.new_tracker(emitter, encode_base64)
  local trck = {}
  setmetatable(trck, Tracker)
  if encode_base64 == nil then
    encode_base64 = DEFAULT_ENCODE_BASE64
  end
  trck.emitter = emitter
  trck.config = {
    encode_base64 = encode_base64,
    platform = DEFAULT_PLATFORM,
    version = TRACKER_VERSION,
  }

  return trck
end

-- --------------------------------------------------------------
-- Private methods

-- Tracks any given SnowPlow event, by sending the specific event_pairs to the SnowPlow collector.
-- @param: self table: The Tracker instance
-- @param pb table: A partially populated payload_builder closure. We will finish populating it in this method, then
-- build() it
-- @return boolean, string: Whether event was successfully collected; and the reason for failure if not
local function track(tracker_instance, pb)
  -- Add the standard name-value pairs
  pb:add("p", tracker_instance.config.platform)
  pb:add("tv", tracker_instance.config.version)
  pb:add("eid", uuid())
  pb:add("dtm", tostring(os.time()))

  -- Fields which may have been set
  local tracker_fields = {
    uid = "user_id",
    aid = "app_id",
    res = "screen_resolution",
    vp = "viewport",
    cd = "color_depth",
  }

  for k, v in pairs(tracker_fields) do
    v = tracker_instance[v]
    if v ~= nil then
      pb:add(k, v)
    end
  end

  local built_payload = pb:build(tracker_instance.emitter:get_request_method())
  return tracker_instance.emitter:send(built_payload)
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
-- @return boolean: whether event was successfully collected; and the reason for failure if not
function Tracker:track_screen_view(name, id)
  validate.is_non_empty_string("name", name)
  validate.is_non_empty_string_or_nil("id", id)

  local screen_view = {
    schema = "iglu:com.snowplowanalytics.snowplow/screen_view/jsonschema/1-0-0",
    data = {
      name = name,
      id = id,
    },
  }

  return self:track_unstruct_event(screen_view)
end

-- Sends a custom structured event to SnowPlow.
-- @param category string: The name you supply for the group of objects you want to track
-- @param action string: A string that is uniquely paired with each category e.g. the type of user interaction for
-- the object
-- @param label string: An optional string to provide additional dimensions to the event data
-- @param property string: An optional string describing the objector the action performed on it.
-- @param value string: A value that you can use to provide numerical data about the user event
-- @return boolean whether event was successfully collected; and the reason for failure if not
function Tracker:track_struct_event(category, action, label, property, value)
  local pb = payload.new_payload_builder(self.config.encode_base64)
  pb:add("e", "se")

  local fields = {
    { "se_ca", "category", category, validate.is_non_empty_string },
    { "se_ac", "action", action, validate.is_non_empty_string },
    { "se_la", "label", label, validate.is_string_or_nil },
    { "se_pr", "property", property, validate.is_string_or_nil },
    { "se_va", "value", value, validate.is_number_or_nil },
  }

  for _, field in ipairs(fields) do
    local parameter, name, var, validator = table.unpack(field)
    validator(name, var)
    -- The value is allowed to be nil, but we don't want to send it as a field if so
    if var ~= nil then
      pb:add(parameter, var)
    end
  end

  return track(self, pb)
end

-- Sends a custom unstructured event to Snowplow.
-- @param properties string: The properties of the event
-- @return: boolean whether event was successfully collected; and the reason for failure if not
function Tracker:track_unstruct_event(properties)
  local wrapper = {
    schema = "iglu:com.snowplowanalytics.snowplow/unstruct_event/jsonschema/1-0-0",
    data = properties,
  }
  local pb = payload.new_payload_builder(self.config.encode_base64)
  pb:add("e", "ue")
  pb:add_table(self.config.encode_base64 and "ue_px" or "ue_pr", wrapper)
  return track(self, pb)
end

-- --------------------------------------------------------------

return tracker
