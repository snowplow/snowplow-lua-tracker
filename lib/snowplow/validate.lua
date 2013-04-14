local validate = {}

-- --------------------------------------------------------------
-- Boolean validations

validate.isBoolean = function (name, value)

  if type(value) ~= "boolean" then
    error(name .. " is required and must be a boolean, not [" .. value .. "]")
  end
end

-- --------------------------------------------------------------
-- Table validations

validate.isNonEmptyTable = function (name, value)

  if type(value) ~= "table" or value == {} then
    error(name .. " is required and must be a non-empty table, not [" .. value .. "]")
  end
end

validate.isTableOrNil = function (name, value)

  if type(value) ~= "table" and value ~= nil then
    error(name .. " must be a table or nil, not [" .. value .. "]")
  end
end

-- --------------------------------------------------------------
-- String validations

validate.isNonEmptyString = function (name, value)

  if type(value) ~= "string" or value == "" then
    error(name .. " is required and must be a string, not [" .. value .. "]")
  end
end

validate.isStringOrNil = function (name, value)

  if type(value) ~= "string" and value ~= nil then
    error(name .. " must be a string or nil, not [" .. value .. "]")
  end
end

validate.isStringFromSet = function (set, name, value)
  --[[--
  Note that set is the first argument, to support
  partial application.
  --]]--

  if type(value) ~= "string" then
    error(name .. " must be a string")
  end

  if not set:contains(value) then
    error(name .. " must be one of " .. set:toString() .. ", not [" .. value .. "]" )
  end
end

-- --------------------------------------------------------------
-- Numeric validations

validate.isNumber = function (name, value)

  if type(value) ~= "number" then
    error(name .. " is required and must be a number, not [" .. value .. "]")
  end
end

validate.isNumberOrNil = function (name, value)

  if type(value) ~= "number" and value ~= nil then
    error(name .. " must be a number or nil, not [" .. value .. "]")
  end
end

validate.isPositiveInteger = function (name, value)

  if type(value) ~= "number" or value ~= math.abs(value) or value < 0 then
    error(name .. "is required and must be a positive integer, not [" .. value .. "]")
  end
end

-- --------------------------------------------------------------

return validate