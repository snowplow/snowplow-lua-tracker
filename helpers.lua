
local osTime = os.time
local mathRandom = math.random
local mathRandomseed = math.randomseed

Helpers = {}

function Helpers.getTransactionId()
  --[[--
  Generates a moderately-unique six-digit transaction ID
  - essentially a nonce to make sure this event isn't
  recorded twice.
  --]]--

  math_randomseed( osTime() )
  local rand = mathRandom(100000, 999999)
  return tostring(rand)
end

function Helpers.getTimestamp()
  --[[--
  Returns the current timestamp as total milliseconds
  since epoch.
  --]]--
  return (osTime() * 1000)
end

function Helpers.toPropertyJSON()
  -- TODO
end

function Helpers.collectorURIFromCf(dist_subdomain)
  --[[--
  Helper to generate the collector url from a
  CloudFront distribution subdomain.

  Example:
  collectorURIFromCf("f3f77d9def5") => "http://f3f77d9def5.cloudfront.net/i"

  @Parameter: dist_subdomain
    The CloudFront subdomain on which the collector's
    distribution is hosted
  --]]--

  return as_collector_url(dist_subdomain .. ".cloudfront.net")
end

function Helpers.asCollectorURI(host)
  --[[--
  Helper to generate the collector url from a
  collector host name.

  Example:
  as_collector_url("snplow.myshop.com") => "http://snplow.myshop.com/i"
  --]]--

  return "http://" .. host .. "/i"
end