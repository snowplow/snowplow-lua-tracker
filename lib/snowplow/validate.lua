local mathAbs = math.abs
local type = type
local error = error

local validate = {}

-- --------------------------------------------------------------
-- Boolean validations

validate.isBool = function (name, value)

  if type(value) ~= "boolean" then
    error(name .. " is required and must be a boolean")
  end
end

-- --------------------------------------------------------------
-- Table validations

validate.isNonEmptyTable = function (name, value)

  if type(value) ~= "table" or value == {} then
    error(name .. " is required and must be a non-empty table")
  end
end

validate.isTableOrNil = function (name, value)

  if type(value) ~= "table" and value ~= nil then
    error(name .. " must be a table or nil")
  end
end

-- --------------------------------------------------------------
-- String validations

validate.isNonEmptyString = function (name, value)

  if type(value) ~= "string" or value == "" then
    error(name .. " is required and must be a string")
  end
end

validate.isStringOrNil = function (name, value)

  if type(value) ~= "string" and value ~= nil then
    error(name .. " must be a string or nil")
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
    error(name .. "must be one of " .. set:toString(", ") )
  end
end

-- --------------------------------------------------------------
-- Numeric validations

validate.isNumber = function (name, value)

  if type(value) ~= "number" then
    error(name .. " is required and must be a number")
  end
end

validate.isNumberOrNil = function (name, value)

  if type(value) ~= "number" and value ~= nil then
    error(name .. " must be a number or nil")
  end
end

validate.isPositiveInt = function (name, value)

  if type(value) ~= "number" or value ~= mathAbs(value) or value < 0 then
    error(name .. "is required and must be a positive integer")
  end
end

-- --------------------------------------------------------------

return validate