local setmetatable = setmetatable
local pairs, ipairs = pairs, ipairs

local set = {}

-- --------------------------------------------------------------
-- Metatable configuration

set.mt = { __index = set }

-- --------------------------------------------------------------
-- Factory to create a set

set.newSet = function (t)
  --[[--
  Creates a new set from the supplied table.
  Taken from: http://www.lua.org/pil/13.1.html

  @Parameter: t
    The table containing the value for this set
  --]]--

  local s = {}
  setmetatable(s, set.mt)
  for _, l in ipairs(t) do s[l] = true end
  return s
end

-- --------------------------------------------------------------
-- Public methods

set.contains = function (self, value)
  --[[--
  Does the set contain this value?

  @Parameter: key
    The value to look for in our set
  --]]--

  return self[value]
end

set.toString = function (self, value)
  --[[--
  Convert a set to a string representation
  Taken from: http://www.lua.org/pil/13.1.html
  --]]--

  local s = "{"
  local sep = ""
  for e in pairs(self) do
    s = s .. sep .. e
    sep = ", "
  end
  return s .. "}"
end

-- --------------------------------------------------------------

return set