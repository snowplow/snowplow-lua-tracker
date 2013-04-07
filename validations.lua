
local Validate = {}

-- -------------------------------
-- String validations

function Validate.isNonEmptyString(name, value)

  if type(value) ~= "string" or value == "" then
    error(name .. " is required and must be a string")
  end
end

function Validate.isStringOrNil(name, value)

  if type(value) ~= "string" and value ~= nil then
    error(name .. " must be a string or nil")
end

function Validate.isStringFromList(list, name, value)

  --[[--
  xxx.
  Note that list is the first argument to support
  partial application.
  --]]--

end

-- -------------------------------
-- Numeric validations

function Validate.isNumber(name, value)

  if type(value) ~= "number" then
    error(name .. " is required and must be a number")
  end
end

function Validate.isNumberOrNil(name, value)

  if type(value) ~= "number" and value ~= nil then
    error(name .. " must be a number or nil")
  end
end

function Validate.isPositiveInt(name, value)

  if type(value) ~= "number" then
    error(name .. "is required and must be a positive integer")
  end

  -- TODO: add rest of validation
end