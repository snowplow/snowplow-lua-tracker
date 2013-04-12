validate = require( "libs.validate" )
payload  = require( "libs.payload" )

module( "snowplow" )

-- -------------------------------
-- Constants

local TRACKER_VERSION = "lua-0.1.0"
local DEFAULT_PLATFORM = "pc"
local SUPPORTED_PLATFORMS = set.new { "pc", "tv", "mob", "con", "iot" }

local config = {
  ENCODE_BASE64 = true
}

-- -------------------------------
-- Constructors

function newTrackerForUri (self, host)
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
end function

function newTrackerForCf (self, cfSubdomain)
  --[[--
  Create a new Snowplow tracker talking to a
  CloudFront-based collector on the given subdomain.

  @Parameter: host
    The CloudFront subdomain on which the
    collector is running
  --]]--

  validate.isNonEmptyString( "cloudfront subdomain", cfSubdomain )
  local uri = collectorURIFromCf( cfSubdomain )
  return newTracker( uri )
end function

-- -------------------------------
-- Public configuration methods

function encodeBase64 (self, encode)
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
  self.config[ENCODE_UNSTRUCT_EVENTS] = encode
end

-- -------------------------------
-- Data setters. All public

function setPlatform (self, platform)
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

  validate.isStringFromSet( SUPPORTED_PLATFORMS, "platform", platform )
  self.platform = platform
end

function setAppId (self, appId)
  --[[--
  Sets the application ID to record against
  each event.

  @Parameter: appId
    The application ID to set
  --]]--

  validate.isNonEmptyString( "app id", appId )
  self.appId = appId
end

function setUserId (self, userId)
  --[[--
  Sets the business user ID.

  @Parameter; userId
    The business user ID to set.
  --]]--

  validate.isNonEmptyString( "user id", userId )
  self.userId = userId
end

function setScreenResolution (self, width, height)
  --[[--
  If you have access to a graphics library which can
  tell you screen width and height, then set it here.

  @Parameter: width
    The screen width as a number
  @Parameter: height
    The screen height as a number
  --]]--

  validate.isPositiveInt( width, "width" )
  validate.isPositiveInt( height, "height" )
  self.width = width
  self.height = height
end

function setColorDepth (self, depth)
  --[[--
  If you have access to a graphics library which can
  tell you screen width and height, then set it here.
  
  @Parameter: depth
    The color depth on this computer
  --]]--

  validate.isPositiveInt( depth, "color depth" )
  self.colorDepth = depth
end

-- -------------------------------
-- Track methods. All public

function trackScreenView (self, name, id)
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

  local pb = payload.newPayloadBuilder( self:configEncodeBase64 )
  pb.addRaw( "e", "sv" )
  pb.add( "sv_na", name, validate.isNonEmptyString )
  pb.add( "sv_id", id, validate.isStringOrNil )

  return self:track( pb )
end

function trackStructEvent (self, category, action, label, property, value)
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

  local pb = payload.newPayloadBuilder( self:configEncodeBase64 )
  pb.addRaw( "e", "se" )
  pb.add( "ev_ca", category, validate.isNonEmptyString )
  pb.add( "ev_ac", action, validate.isNonEmptyString )
  pb.add( "ev_la", label, validate.isStringOrNil )
  pb.add( "ev_pr", property, validate.isStringOrNil )
  pb.add( "ev_va", value, validate.isNumberOrNil )

  return self:track( pb )
end

function trackUnstructEvent (self, name, properties)
  --[[--
  Sends a custom unstructured event to Snowplow.

  @Parameter: name
    TODO
  @Parameter: properties
    TODO
  --]]--

  local pb = payload.newPayloadBuilder( self:configEncodeBase64 )
  pb.addRaw("e", "ue")
  pb.add( "ue_na", name, validate.isNonEmptyString )
  pb.addProps( "ue_px", "ue_pr", props, validate.isNonEmptyTable )

  return self:track( pb )
end

-- -------------------------------
-- Private methods

local function Snowplow:configEncodeBase64 ()
  --[[--
  Alias to wrap whether unstruct events should
  be base64-encoded or not.
  --]]--
  return self.config[ENCODE_BASE64]
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
  pb.add( "tid", getTransactionId() )
  pb.add( "p", self.platform )
  pb.add( "uid", self.userId )
  pb.add( "aid", self.appId )
  pb.add( "dtm", getTimestamp() )
  pb.add( "tv", TRACKER_VERSION )

  -- Now build the payloadBuilder
  local payload = pb.build()

  -- Finally send to Snowplow
  return httpGet (self.collectorUri .. payload)
end

-- -------------------------------
-- Private functions aka 'static' methods

local function newTracker (uri)
  --[[--
  Builds our new tracker using the supplied URI.

  @Parameter: uri
    The full URI to the Snowplow collector
  --]]--

  validate.isNonEmptyString( uri )
  return {
    config       = config,
    collectorURI = uri
  }
end function

local function collectorUriFromCf (dist_subdomain)
  --[[--
  Helper to generate the collector url from a
  CloudFront distribution subdomain.

  Example:
  collectorUriFromCf("f3f77d9def5") => "http://f3f77d9def5.cloudfront.net/i"

  @Parameter: dist_subdomain
    The CloudFront subdomain on which the collector's
    distribution is hosted
  --]]--

  return asCollectorUri(dist_subdomain .. ".cloudfront.net")
end

local function asCollectorUri (host)
  --[[--
  Helper to generate the collector url from a
  collector host name.

  Example:
  as_collector_url("snplow.myshop.com") => "http://snplow.myshop.com/i"
  --]]--

  return "http://" .. host .. "/i"
end

local function getTransactionId ()
  --[[--
  Generates a moderately-unique six-digit transaction ID
  - essentially a nonce to make sure this event isn't
  recorded twice.
  --]]--

  mathRandomseed( osTime() )
  local rand = mathRandom(100000, 999999)
  return tostring(rand)
end

local function getTimestamp ()
  --[[--
  Returns the current timestamp as total milliseconds
  since epoch.
  --]]--
  return osTime() * 1000
end

local function httpGet (uri)
  --[[--
  GETs the given URI: this is how our event data
  is transmitted to the Snowplow collector.

  @Parameter: uri
    The URI (including querystring) to GET
  --]]--

  result, statuscode, content = http.request(uri)

  -- TODO: add error handling
end
