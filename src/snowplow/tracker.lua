-- tracker.lua
--
-- Copyright (c) 2013 - 2022 Snowplow Analytics Ltd. All rights reserved.
--
-- This program is licensed to you under the Apache License Version 2.0,
-- and you may not use this file except in compliance with the Apache License Version 2.0.
-- You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the Apache License Version 2.0 is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.

--- The Snowplow tracker
-- @module Tracker
-- @author Alex Dean
-- @copyright Copyright (c) 2013 - 2022 Snowplow Analytics Ltd
-- @license Apache License Version 2.0

local validate = require("validate")
local payload = require("payload")
local set = require("lib.set")
local uuid = require("uuid")
local TRACKER_VERSION = require("constants").TRACKER_VERSION

--- The Tracker table.
-- @func encode_base64
-- @func platform
-- @func set_app_id
-- @func set_user_id
-- @func set_screen_resolution
-- @func set_viewport
-- @func set_color_depth
-- @func track_screen_view
-- @func track_struct_event
-- @func track_self_describing_event
-- @table Tracker

local tracker = {} -- The module
local Tracker = {} -- The class
Tracker.__index = Tracker

-- Constants & config

local DEFAULT_ENCODE_BASE64 = true
local DEFAULT_PLATFORM = "pc"
local SUPPORTED_PLATFORMS = set.new_set({ "pc", "tv", "mob", "cnsl", "iot" })

--- Creates a new tracker instance.
-- @tparam Emitter emitter The emitter to use to send the payloads
-- @bool[opt=true] encode_base64 Whether to base64 encode the payloads
-- @treturn Tracker The new tracker
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

--- Tracks any given Snowplow event, by sending the specific event_pairs to the Snowplow collector.
-- @tparam Tracker tracker_instance
-- @tparam Payload pb A partially populated payload_builder closure.
-- @return boolean, string Whether event was successfully collected; and the reason for failure if not
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

  return tracker_instance.emitter:send(pb, tracker_instance)
end

-- --------------------------------------------------------------
-- Configuration methods

--- Configuration setting: whether to Base64-encode the properties of unstructured events and custom variables.
-- Encoding means a circa~25% space saving.
-- Defaults to true.
-- @bool encode Whether to base64-encode or not
function Tracker:encode_base64(encode)
  validate.is_boolean("encode", encode)
  self.config.encode_base64 = encode
end

--- The default platform for Lua is "pc". If you are using Lua on another platform,
-- (e.g. as part of a console videogame), you can change the platform here.
-- For details on the different platforms, see:
-- https://github.com/snowplow/snowplow/wiki/SnowPlow-Tracker-Protocol#wiki-appid
-- @string platform The short-form name of the platform to set. Can be "pc", "tv", "mob", "csl" or "iot".
function Tracker:platform(platform)
  validate.is_string_from_set(SUPPORTED_PLATFORMS, "platform", platform)
  self.config.platform = platform
end

-- --------------------------------------------------------------
-- Data setters

--- Sets the application ID.
-- @string app_id The application ID to set
function Tracker:set_app_id(app_id)
  validate.is_non_empty_string("app_id", app_id)
  self.app_id = app_id
end

--- Sets the business user ID.
-- @string user_id The business user ID to set.
function Tracker:set_user_id(user_id)
  validate.is_non_empty_string("user_id", user_id)
  self.user_id = user_id
end

--- Sets the screen resolution.
-- @number width The screen width
-- @number height The screen height
function Tracker:set_screen_resolution(width, height)
  validate.is_positive_integer("width", width)
  validate.is_positive_integer("height", height)
  self.screen_resolution = width .. "x" .. height
end

--- Sets the viewport size.
-- @number width The viewport width
-- @number height The viewport height
function Tracker:set_viewport(width, height)
  validate.is_positive_integer("width", width)
  validate.is_positive_integer("height", height)
  self.viewport = width .. "x" .. height
end

--- Sets the bit depth of the color palette.
-- @number depth The color depth on this computer
function Tracker:set_color_depth(depth)
  validate.is_positive_integer("depth", depth)
  self.color_depth = depth
end

-- --------------------------------------------------------------
-- Track methods

--- Sends a screen view event to Snowplow. A screen view must have a `name` and can have an optional `id`.
-- @string name Human-readable name for this screen (e.g. "HUD > Save Game").
-- @string id Optional unique identifier for this screen. Could be e.g. a GUID or identifier from a game CMS
-- @treturn boolean Whether event was successfully collected
-- @treturn ?string The reason for failure if not
function Tracker:track_screen_view(name, id)
  validate.is_non_empty_string("name", name)
  validate.is_non_empty_string_or_nil("id", id)

  return self:track_self_describing_event("iglu:com.snowplowanalytics.snowplow/screen_view/jsonschema/1-0-0", {
    name = name,
    id = id,
  })
end

--- Sends a custom structured event to Snowplow.
-- @string category The category of event
-- @string action The action / event itself
-- @string[opt] label The ‘object’ the action is performed on
-- @string[opt] property A property associated with either the action or the object
-- @string[opt] value A value associated with the user action
-- @treturn boolean Whether event was successfully collected
-- @treturn ?string The reason for failure if not
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

--- Sends a custom unstructured event to Snowplow.
-- @tab schema The schema for this event
-- @tab data The key, value pairs to send with the event
-- @treturn boolean Whether event was successfully collected
-- @treturn ?string The reason for failure if not
function Tracker:track_self_describing_event(schema, data)
  validate.is_non_empty_string("schema", schema)
  validate.is_non_empty_table("data", data)

  local wrapper = {
    schema = "iglu:com.snowplowanalytics.snowplow/unstruct_event/jsonschema/1-0-0",
    data = {
      schema = schema,
      data = data,
    },
  }
  local pb = payload.new_payload_builder(self.config.encode_base64)
  pb:add("e", "ue")
  pb:add_table(self.config.encode_base64 and "ue_px" or "ue_pr", wrapper)
  return track(self, pb)
end

-- --------------------------------------------------------------

return tracker
