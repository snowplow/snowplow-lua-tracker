local math = require ("math")

-- TODO: how to specify importing only math in a module?

module(...)

-- -------------------------------
-- String validations

function isNonEmptyString (name, value)

  if type(value) ~= "string" or value == "" then
    error(name .. " is required and must be a string")
  end
end

function isStringOrNil (name, value)

  if type(value) ~= "string" and value ~= nil then
    error(name .. " must be a string or nil")
end

function isStringFromList (list, name, value)
  --[[--
  xxx.
  Note that list is the first argument to support
  partial application.
  --]]--

  if type(value) ~= "string" then
    error(name .. " must be a string")
  end

  if not list:contains(value) then
    error(name .. "must be one of " .. list:mkString(", ") )
  end
end

-- -------------------------------
-- Numeric validations

function isNumber (name, value)

  if type(value) ~= "number" then
    error(name .. " is required and must be a number")
  end
end

function isNumberOrNil (name, value)

  if type(value) ~= "number" and value ~= nil then
    error(name .. " must be a number or nil")
  end
end

function isPositiveInt (name, value)

  if type(value) ~= "number" or value ~= math.abs(value) or value < 0 then
    error(name .. "is required and must be a positive integer")
  end
end