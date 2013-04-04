

module("snowplow-payload")

function newPayloadBuilder (initial_value)

  local payload

  -- Type and value checks
  if type(initial_value) ~= "string" and initial_value ~= nil then
    error("initial_value must be a string or nil")
  end

  -- Initialize
  if initial_value then
    payload = initial_value
  else
    payload = ""
  end

  local add_nv_pair = function (key, value, encode)
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
            add_nv_pair(key, value, true)
          end,

    add_raw = function (key, value)
                --[[--
                Add a &name=value pair with the value
                not encoded.
                --]]--
                add_nv_pair(key, value, false)
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