local http = require( "socket.http" )

local osTime = os.time
local mathRandom = math.random
local mathRandomseed = math.randomseed

module( "payload" )

function newPayloadBuilder (encodeBase64)

  local payload = "?"

  local addNvPair = function (key, value, encode)
    --[[--
    Helper to add a &name=value pair to our payload
    aka querystring. Closes around payload
    --]]--

    local a, v

    if value ~= nil and value ~= "" then
      if payload:len() > 0 then a = "&" else a = "" end
      if encode then v = value else v = value end
      payload = payload .. a .. key .. "=" .. v
    end
  end

  -- Return a table of closure functions to build
  -- our payload string.
  return {
    add = function (key, value, validate)
            --[[--
            Add a &name=value pair with the value encoded,
            --]]--
            validate( key, value )
            addNvPair( key, value, true )
          end,

    addRaw = function (key, value, validate)
                --[[--
                Add a &name=value pair with the value
                not encoded.
                --]]--
                validate( key, value )
                addNvPair( key, value, false )
              end,

    addProperties = function (keyIfEnc, key, value, validate)
                  --[[--
                  Add a &name=value pair with the value
                  base64 encoded, unless encodeBase64 is set
                  to false (in which case URI escape).
                  --]]--

                  validate( key, value )
                  props = toPropertiesJson( value )

                  if encodeBase64 then
                    addNvPair( keyIfEnc, base64.encode( value ), false) -- No URI escaping
                  else
                    addNvPair( key, value, true ) -- URI escaping
                  end,

    build = function ()
              --[[--
              Our "builder" returns the closed-over
              payload string.
              --]]--
              return payload
            end
  }
end

function toPropertiesJson (properties)
  --[[--
  Converts a _non-nested_ Lua table into a JSON
  of properties.
  
  @Parameter: properties
    A non-nested Lua table of properties, to be
    converted to JSON format
  --]]--

  -- TODO: write this code
end
