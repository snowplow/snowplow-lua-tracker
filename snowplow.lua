
-- TODO: check this assignment will work
base64 = require ( "libs.base64" )

module("snowplow")

-- -------------------------------
-- Constants

-- Syntax for constants in Lua?
local TRACKER_VERSION = "lua-0.1.0"
local DEFAULT_PLATFORM = "pc"
local SUPPORTED_PLATFORMS = set.new { "pc", "tv", "mob", "con", "iot" }

local config = {
  ENCODE_UNSTRUCT_EVENTS = true,
  ERROR_ON_TRACK = false,
  ERROR_ON_VALIDATE = true
}

-- -------------------------------
-- Constructors

function Snowplow.newTrackerForURI (host)
  --[[--
  Create a new Snowplow tracker talking to a
  URI-based collector on the given host.

  @Parameter: host
    The host (i.e. full domain) on which the
    collector is running
  --]]--

  Validate.isNonEmptyString( "host", host )
  local uri = helpers.asCollectorURI( host )
  return newTracker( uri )
end function

function Snowplow.newTrackerForCf (cfSubdomain)
  --[[--
  Create a new Snowplow tracker talking to a
  CloudFront-based collector on the given subdomain.

  @Parameter: host
    The CloudFront subdomain on which the
    collector is running
  --]]--

  Validate.isNonEmptyString( "cloudfront subdomain", cfSubdomain )
  local uri = helpers.collectorURIFromCf( cfSubdomain )
  return newTracker( uri )
end function

-- -------------------------------
-- Public configuration methods, plus
-- private convenience ? methods to
-- use in our code.

function Snowplow:encodeUnstructEvents (encode)
  --[[--
  Configuration setting: whether to Base64-encode the
  properties of unstructured events.
  Encoding means a circa 25% space saving.

  Defaults to true.

  @Parameter: encode
    Boolean: whether to base64-encode or not
  --]]--

  Validate.isBoolean( "encode", encode )
  self.config[ENCODE_UNSTRUCT_EVENTS] = encode
end

function Snowplow:errorOnTrack (err)
  --[[--
  Configuration setting: whether to throw an error
  if tracking an event fails.

  Defaults to false. Recommend only setting to true
  when testing.

  @Parameter: err
    Boolean: whether to throw an error on tracking
    failure
  --]]--

  Validate.isBoolean( "err", err )
  self.config[ERROR_ON_TRACK] = err
end

function Snowplow:errorOnValidate (err)
  --[[--
  Configuration setting: whether to throw an error
  if validating an event fails.

  Defaults to true. Assumption is that all validation
  errors can be identified and fixed at development time.

  @Parameter: err
    Boolean: whether to throw an error on validation
    failure.
  --]]--

  Validate.isBoolean( "err", err )
  self.config[ERROR_ON_VALIDATE] = err
end

-- -------------------------------
-- Data setters. All public

function Snowplow:setPlatform (platform)
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

  Validate.isStringFromSet(SUPPORTED_PLATFORMS, "platform", platform)
  self.platform = platform
end

function Snowplow:setAppId (appId)
  --[[--
  Sets the application ID to record against
  each event.

  @Parameter: appId
    The application ID to set
  --]]--

  Validate.isNonEmptyString( appId )
  self.appId = appId
end

function Snowplow:setUserId (userId)
  --[[--
  Sets the business user ID.

  @Parameter; userId
    The business user ID to set.
  --]]--

  Validate.isNonEmptyString(userId)
  self.userId = userId
end

function Snowplow:setScreenResolution (width, height)
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

function Snowplow:setColorDepth (depth)
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

function Snowplow:trackScreenView (name, id)
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

  local pb = helpers.newPayloadBuilder()
  pb.addRaw( "e", "sv" )
  pb.add( "sv_na", name, Validate.isNonEmptyString )
  pb.add( "sv_id", id, Validate.isStringOrNil )

  self:track(pb)
end

function Snowplow:trackStructEvent (category, action, label, property, value)
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

  local pb = helpers.newPayloadBuilder()
  pb.addRaw( "e", "se" )
  pb.add( "ev_ca", category, Validate.isNonEmptyString )
  pb.add( "ev_ac", action, Validate.isNonEmptyString )
  pb.add( "ev_la", label, Validate.isStringOrNil )
  pb.add( "ev_pr", property, Validate.isStringOrNil )
  pb.add( "ev_va", value, isNumberOrNil )

  self:track(pb)
end

function Snowplow:trackUnstructEvent (name, properties)

  --[[--
  Sends a custom unstructured event to Snowplow.

  @Parameter: name
    TODO
  @Parameter: properties
    TODO
  --]]--

  local pb = helpers.newPayloadBuilder()
  pb.addRaw("e", "ue")
  pb.add( "ue_na", name, Validate.isNonEmptyString )

  local props = helpers.toPropertiesJSON( properties )
  if self:encodeUnstructEvents? then
    -- TODO: cross-check that JS tracker is moving to URL-safe format too
    pb.addRaw( "ue_px", base64.encode( props ) )
  else
    pb.addRaw( "ue_pr", props )
  end

  self:track(pb)
end

-- -------------------------------
-- Private methods

local function Snowplow.newTracker (uri)
  --[[--
  Builds our new tracker using the supplied URI.

  @Parameter: uri
    The full URI to the Snowplow collector
  --]]--

  Validate.isNonEmptyString( uri )
  return {
    config       = config,
    collectorURI = uri
  }
end function

local function Snowplow:configEncodeUnstructEvents ()
  return self.config[ENCODE_UNSTRUCT_EVENTS]
end

local function Snowplow:configErrorOnTrack ()
  return self.config[ERROR_ON_TRACK]
end

local function Snowplow:configErrorOnValidate ()
  return self.config[ERROR_ON_VALIDATE]
end

local function Snowplow:track (pb)
  --[[--
  Tracks any given SnowPlow event, by sending the specific
  event_pairs to the SnowPlow collector.

  @Parameter: pb
    A partially populated payloadBuilder closure. We will
    finish populating it in this method, then build() it
  --]]--

  -- Add the standard name-value pairs
  pb.add( "tid", helpers.getTransactionId() )
  pb.add( "p", self.platform )
  pb.add( "uid", self.userId )
  pb.add( "aid", self.appId )
  pb.add( "dtm", helpers.getTimestamp() )
  pb.add( "tv", TRACKER_VERSION )

  -- Now build the payloadBuilder
  local payload = pb.build()

  -- Finally send to Snowplow
  -- TODO
end