local escape = require( "3rdparty.escape" )
local json   = require( "3rdparty.JSON" )
local base64 = require( "3rdparty.base64" )

module( "payload" )

function newPayloadBuilder (encodeBase64)
  return {
    payload = "?"
  }
end

function add (self, key, value, validate)
  --[[--
  Add a &name=value pair with the value encoded,
  --]]--
  validate( key, value )
  self:addNvPair( key, value, true )
end

function addRaw (key, value, validate)
  --[[--
  Add a &name=value pair with the value
  not encoded.
  --]]--
  validate( key, value )
  self:addNvPair( key, value, false )
end

function addProps (keyIfEnc, key, value, validate)
  --[[--
  Add a &name=value pair with the value
  base64 encoded, unless encodeBase64 is set
  to false (in which case URI escape).
  --]]--

  validate( key, props )
  props = toPropertiesJson( value )

  if encodeBase64 then
    addNvPair( keyIfEnc, base64.encode( props ), false) -- Base64 encode, no URI escaping
  else
    addNvPair( key, props, true ) -- URI escaping
  end
end

function build (self)
  --[[--
  Our "builder" returns the payload string.
  --]]--
  return self.payload
end

local function addNvPair (self, key, value, esc)
  --[[--
  Helper to add a &name=value pair to our payload
  aka querystring. Closes around payload
  --]]--

  local a, v

  if value ~= nil and value ~= "" then
    if self.payload:len() > 0 then a = "&" else a = "" end
    if esc then v = escape.escapeUri( value ) else v = value end
    self.payload = self.payload .. a .. key .. "=" .. v
  end
end

local function toPropertiesJson (properties)
  --[[--
  Converts a _non-nested_ Lua table into a JSON
  of properties.
  
  @Parameter: properties
    A non-nested Lua table of properties, to be
    converted to JSON format
  --]]--

  -- TODO: write this code
end
