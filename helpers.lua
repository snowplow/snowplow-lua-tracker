
-- TODO: how to import these via a module statement?
local osTime = os.time
local mathRandom = math.random
local mathRandomseed = math.randomseed

module(...)

function newPayloadBuilder (initialValue)

  local payload

  -- Type and value checks
  if type(initialValue) ~= "string" and initialValue ~= nil then
    error("initial_value must be a string or nil")
  end

  -- Initialize
  if initialValue then
    payload = initialValue
  else
    payload = ""
  end

  local addNvPair = function (key, value, encode)
    --[[--
    Helper to add a &name=value pair to our payload
    aka querystring. Closes around payload
    --]]--

    local a, v

    if value ~= nil and value ~= "" then
      if payload:len() > 0 then a = "&" else a = "" end

      -- TODO: add in encoding to the below
      if encode then v = value else v = value end

      payload = payload .. a .. key .. "=" .. v
    end
  end

  -- Return a table of closure functions to build
  -- our payload string.
  return {
    add = function (key, value)
            --[[--
            Add a &name=value pair with the value encoded,
            --]]--
            addNvPair(key, value, true)
          end,

    addRaw = function (key, value)
                --[[--
                Add a &name=value pair with the value
                not encoded.
                --]]--
                addNvPair(key, value, false)
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

  math_randomseed( osTime() )
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

function toPropertiesJSON ()
  --[[--
  Converts a _non-nested_ Lua table into a JSON
  of properties.
  --]]--
end

function collectorURIFromCf (dist_subdomain)
  --[[--
  Helper to generate the collector url from a
  CloudFront distribution subdomain.

  Example:
  collectorURIFromCf("f3f77d9def5") => "http://f3f77d9def5.cloudfront.net/i"

  @Parameter: dist_subdomain
    The CloudFront subdomain on which the collector's
    distribution is hosted
  --]]--

  return asCollectorURI(dist_subdomain .. ".cloudfront.net")
end

function asCollectorURI (host)
  --[[--
  Helper to generate the collector url from a
  collector host name.

  Example:
  as_collector_url("snplow.myshop.com") => "http://snplow.myshop.com/i"
  --]]--

  return "http://" .. host .. "/i"
end

function getURI (uri)
  --[[--
  GETs the given URL: this is how our event data
  is transmitted to the Snowplow collector.

  @Parameter: uri
    The URI (including querystring) to GET
  --]]--

  -- TODO: GET the URI
end