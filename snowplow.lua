local osTime = os.time
local mathRandom = math.random
local mathRandomseed = math.randomseed

module("snowplow")

-- -------------------------------
-- Constants

-- Syntax for constants in Lua?
local TRACKER_VERSION = "lua-0.1.0"
local DEFAULT_PLATFORM = "pc"
local SUPPORTED_PLATFORMS = {"pc", "tv", "mob", "con", "iot"}

-- -------------------------------
-- "Static" module functions

local function getTransactionId()
  --[[--
  Generates a moderately-unique six-digit transaction ID
  - essentially a nonce to make sure this event isn't
  recorded twice.
  --]]--

  math_randomseed( osTime() )
  local rand = mathRandom(100000, 999999)
  return tostring(rand)
end

local function getTimestamp()
  --[[--
  Returns the current timestamp as total milliseconds
  since epoch.
  --]]--
  return (osTime() * 1000)
end

-- -------------------------------
-- Setters. All public

function setPlatform(platform)
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

  Validate.isStringFromList(SUPPORTED_PLATFORMS, "platform", platform)
  self.platform = platform
end

function setUserId(userId)
  --[[--
  Sets the business user ID.

  @Parameter; userId
    The business user ID to set.
  --]]--

  Validate.isNonEmptyString(userId)
  self.businessUserId = userId
end

function setScreenResolution(width, height)
  --[[--
  If you have access to a graphics library which can
  tell you screen width and height, then set it here.

  @Parameter: width
    The screen width as a number
  @Parameter: height
    The screen height as a number
  --]]--

  Validate.isPositiveInt(value, "width", width)
  Validate.isPositiveInt(value, "height", height)
  self.width = width
  self.height = height
end

function setColorDepth(depth)
  --[[--
  If you have access to a graphics library which can
  tell you screen width and height, then set it here.
  
  @Parameter: depth
    The color depth on this computer
  --]]--

  Validate.isPositiveInt(value, "color depth", depth)
  self.colorDepth = depth
end

-- -------------------------------
-- Track methods. All public

function trackScreenView(name, id)
  --[[--
  Sends a screen view event to SnowPlow. A screen view
  must have a `name` and can have an optional `id`.

  @Parameter: name
    Human-readable name for this screen (e.g.
    "HUD > Save Game"). String
  @Parameter: id
    Optional unique identifier for this screen. Could be e.g.
    a GUID or identifier from a game CMS. String
  --]]--

  local pb = newPayloadBuilder()
  pb.addRaw( "e", "sv" )
  pb.add( "sv_na", name, Validate.isNonEmptyString )
  pb.add( "sv_id", id, Validate.isStringOrNil )

  self:track(pb)
end

function trackStructEvent(category, action, label, property, value)
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

  local pb = newPayloadBuilder()
  pb.addRaw( "e", "se" )
  pb.add( "ev_ca", category, Validate.isNonEmptyString )
  pb.add( "ev_ac", action, Validate.isNonEmptyString )
  pb.add( "ev_la", label, Validate.isStringOrNil )
  pb.add( "ev_pr", property, Validate.isStringOrNil )
  pb.add( "ev_va", value, isNumberOrNil )

  self:track(pb)
end

function trackUnstructEvent(name, properties)

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

  local pb = newPayloadBuilder()
  pb.addRaw("e", "ue")
  pb.add( "ue_na", name, Validate.isNonEmptyString )
  -- TODO: add in "ue_pr"/"ue_px"

  self:track(pb)
end

-- -------------------------------
-- Private methods

local function track(pb)
  --[[--
  Tracks any given SnowPlow event, by sending the specific
  event_pairs to the SnowPlow collector.

  @Parameter: payloadBuilder
    A partially populated payloadBuilder closure. We will
    finish populating it in this method, then build() it
  --]]--

  -- Add the standard name-value pairs
  pb.add( "tid", getTransactionId() )
  pb.add( "p", self.platform )
  pb.add( "uid", self.businessUserId )
  pb.add( "aid", self.applicationId )
  pb.add( "dtm", getTimestamp() )
  pb.add( "tv", TRACKER_VERSION )

  -- Now build the payloadBuilder
  local payload = pb.build()

  -- Finally send to Snowplow
  -- TODO
end