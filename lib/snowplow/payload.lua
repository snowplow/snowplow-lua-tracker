local escape = require( "lib.escape" )
local json   = require( "lib.JSON" )
local base64 = require( "lib.base64" )

local payload = {}

-- --------------------------------------------------------------
-- Factory to create a payload builder closure

payload.newPayloadBuilder = function (encodeBase64)
  --[[--
  Closure provides a fluent interface to building
  a new payload for Snowplow.

  @Parameter: encodeBase64
    Whether properties and custom variables should
    be sent Base64 encoded or not
  --]]--

  payload = "?" -- What we're closing over

  local addNvPair = function (key, value, esc)
    --[[--
    Helper to add a &name=value pair to our payload
    aka querystring. Closes around payload
    --]]--

    local a, v

    if value ~= nil and value ~= "" then
      if payload:len() > 1 then a = "&" else a = "" end
      if esc then v = escape.escapeUri( value ) else v = value end
      payload = payload .. a .. key .. "=" .. v
    end
  end

  local toPropertiesJson = function (properties)
    --[[--
    Converts a _non-nested_ Lua table into a JSON
    of properties.
    
    @Parameter: properties
      A non-nested Lua table of properties, to be
      converted to JSON format
    --]]--

    -- TODO: write this code
    return properties
  end

  local add = function (key, value, validate)
    --[[--
    Add a &name=value pair with the value encoded,
    --]]--
    if type(validate) == "function" then
      validate( key, value )
    end
    addNvPair( key, value, true )
  end

  local addRaw = function (key, value, validate)
    --[[--
    Add a &name=value pair with the value
    not encoded.
    --]]--
    if type(validate) == "function" then
      validate( key, value )
    end
    addNvPair( key, value, false )
  end

  local addProps = function (keyIfEnc, key, value, validate)
    --[[--
    Add a &name=value pair with the value
    base64 encoded, unless encodeBase64 is set
    to false (in which case URI escape).
    --]]--

    if type(validate) == "function" then
      validate( key, props )
    end
    props = toPropertiesJson( value )

    if encodeBase64 then
      addNvPair( keyIfEnc, base64.encode( props ), false) -- Base64 encode, no URI escaping
    else
      addNvPair( key, props, true ) -- URI escaping
    end
  end

  local build = function ()
    --[[--
    Our "builder" returns the payload string.
    --]]--
    return payload
  end

  return {
    add      = add,
    addRaw   = addRaw,
    addProps = addProps,
    build    = build
  }
end

-- --------------------------------------------------------------

return payload