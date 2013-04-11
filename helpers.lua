
local http = require( "socket.http" )

local osTime = os.time
local mathRandom = math.random
local mathRandomseed = math.randomseed

module( "helpers" )

function newPayloadBuilder (encodeBase64)

  local payload = ""

  -- Type and value checks
  validate.isNonEmptyString( "initial value", initialValue )

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

    addProperties = function (key, value, validate)
                  --[[--
                  Add a &name=value pair with the value
                  base64 encoded, unless encodeBase64 is set
                  to false (in which case URI escape).
                  --]]--
                  validate( key, value )

                  if encodeBase64 then
                    addNvPair( key, base64.encode( value ), false)
                  else
                    addNvPair( key, value, true )
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

function getTransactionId ()
  --[[--
  Generates a moderately-unique six-digit transaction ID
  - essentially a nonce to make sure this event isn't
  recorded twice.
  --]]--

  mathRandomseed( osTime() )
  local rand = mathRandom(100000, 999999)
  return tostring(rand)
end

function getTimestamp ()
  --[[--
  Returns the current timestamp as total milliseconds
  since epoch.
  --]]--
  return (osTime() * 1000)
end

function toPropertiesJSON (properties)
  --[[--
  Converts a _non-nested_ Lua table into a JSON
  of properties.
  
  @Parameter: properties
    A non-nested Lua table of properties, to be
    converted to JSON format
  --]]--
end

function collectorURIFromCf (dist_subdomain)
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

function asCollectorUri (host)
  --[[--
  Helper to generate the collector url from a
  collector host name.

  Example:
  as_collector_url("snplow.myshop.com") => "http://snplow.myshop.com/i"
  --]]--

  return "http://" .. host .. "/i"
end

function getUri (uri)
  --[[--
  GETs the given URI: this is how our event data
  is transmitted to the Snowplow collector.

  @Parameter: uri
    The URI (including querystring) to GET
  --]]--

  result, statuscode, content = http.request(uri)

  -- TODO: add error handling
end