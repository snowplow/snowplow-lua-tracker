

function collector_url_from_cf(dist_subdomain)
	--[[--
	Helper to generate the collector url from a
	CloudFront distribution subdomain.

	Example:
	collector_host_from_cf("f3f77d9def5") => "http://f3f77d9def5.cloudfront.net/i"

	@Parameter: dist_subdomain
		The CloudFront subdomain on which the collector's
		distribution is hosted
	--]]--

	return as_collector_url(dist_subdomain .. ".cloudfront.net")
end

function as_collector_url(host)
	--[[--
	Helper to generate the collector url from a
	collector host name.

	Example:
	as_collector_url("snplow.myshop.com") => "http://snplow.myshop.com/i"
	--]]--

	return "http://" .. host .. "/i"
end

function encode_unstruct_events(encode)
	--[[--
	Configuration setting: whether to Base64-encode the properties
	of unstructured events.

	Encoding means a circa 25% space saving.

	@Parameter: encode
		If true, Base64-encode the unstructured events' properties.
		If false, don't.
	--]]--

	  -- Type and value checks
  if type(encode) ~= "boolean" then
    error("category is required and must be a boolean")
  end

  -- Set
  self.config['encode_unstruct_events'] = encode
 end