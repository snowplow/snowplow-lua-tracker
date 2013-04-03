local os_time = os.time
local math_random = math.random
local math_randomseed = math.randomseed

module("snowplow")

-- -------------------------------
-- Constants

-- Syntax for constants in Lua?
local TRACKER_VERSION = "lua-0.1.0"
local DEFAULT_TRACKER_PLATFORM = "pc"
local SUPPORTED_TRACKER_PLATFORMS = {"pc", "tv", "mob", "con", "iot"}

-- -------------------------------
-- Setters

function set_platform(platform)
  --[[--
  The default platform for Lua is "pc". If you are using Lua on
  another platform (e.g. as part of a console videogame), you
  can overwrite the platform here.

  @Parameter: platform
    The short-form name of the platform to set. Can be "pc",
    "tv", "mob", "con" or "iot".
    For details see:
    XXX
  --]]--
end

function set_user_id(user_id)
  --[[--
  Sets the business user_id.

  @Parameter; user_id
    The business user_id to set.
  --]]--
end

function set_screen_resolution(width, height)
  --[[--
  If you have access to a graphics library which can
  tell you screen width and height, then set it here.

  @Parameter: width
    The screen width as a number
  @Parameter: height
    The screen height as a number
  --]]--

  -- Type and value checks
  if type(width) ~= "number" then
    error("width is required and must be a number")
  elseif type(height) ~= "number" then
    error("height is required and must be a number")
  end

  -- TODO
  -- TODO
end

function set_colordepth()

-- -------------------------------
-- Track functions

function track_screen_view(name, id)
  --[[--
  Sends a screen view event to SnowPlow. A screen view
  must have a `name` and can have an optional `id`.

  @Parameter: name
    Human-readable name for this screen (e.g.
    "HUD > Save Game")
  @Parameter: id
    Unique identifier for this screen. Could be e.g. a GUID or
    identifier from a game CMS.
  --]]--
end

function track_struct_event(category, action, label, property, value)
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
  --]]--

  -- Type and value checks
  if type(category) ~= "string" or category == "" then
    error("category is required and must be a string")
  elseif type(action) ~= "string" or action == "" then
    error("action is required and must be a string")
  elseif type(label) ~= "string" and label ~= nil then
    error("label must be a string or nil")
  elseif type(property) ~= "string" and property ~= nil then
    error("property must be a string or nil")
  elseif type(value) ~= "number" and value ~= nil then
    "value must be a number or nil")
  end

  -- Now let's build the table
  -- TODO: we should use a QuerystringBuilder instead
  pairs = {
    { "e", "se" },
    { "ev_ca", category },
    { "ev_ac", action },
    { "ev_la", label },
    { "ev_pr", property },
    { "ev_va", value }
  } 

  -- Finally call track
  track(pairs)
end

function track_struct_event(name, properties)

  --[[--
  Sends a custom unstructured event to SnowPlow.

  @Parameter: name
    TODO
  @Parameter: properties
    TODO
  --]]--

  -- Type and value checks
  if type(name) ~= string or name == "" then
    error("name is required and must be a string")
    -- TODO: validate properties
  end
end

-- -------------------------------
-- "Static" module functions below

local function get_transaction_id()
  --[[--
  Generates a moderately-unique six-digit transaction ID
  - essentially a nonce to make sure this event isn't
  recorded twice.
  --]]--

  math_randomseed( os_time() )
  local rand = math_random(100000, 999999)
  return tostring(rand)
end

local function get_timestamp()
  --[[--
  Returns the current timestamp as total milliseconds
  since epoch.
  --]]--
  return (os_time() * 1000)
end

local function track(event_pairs)
  --[[--
  Tracks any given SnowPlow event, by sending the specific
  event_pairs to the SnowPlow collector.

  @Parameter: event_pairs
    A table containing all of the name-value pairs
    to be tracked as part of this event
  --]]--

  -- Standard pairs
  -- TODO: we should use a QuerystringBuilder instead
  local pairs = {
    { "tid", get_transaction_id() },
    { "p",   platform },
    { "uid", user_id },
    { "aid", application_id },
    { "dtm", get_timestamp() },
    { "tv",  TRACKER_VERSION }
  }

  -- Concatenate with event_pairs
  -- TODO
end
