

module("snowplow-payload")

function newPayloadBuilder (initial_value)

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
    aka querystring. Closure around payload
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