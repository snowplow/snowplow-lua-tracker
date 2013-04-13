local setmetatable = setmetatable
local pairs, ipairs = pairs, ipairs

module( "set" )

-- local Set = {}
-- Set.mt = { __index = Set }

function newSet (t)
  --[[--
  Creates a new set from the supplied table.
  Taken from: http://www.lua.org/pil/13.1.html

  @Parameter: t
    The table containing the value for this set
  --]]--

  local set = {}
  -- setmetatable(set, Set.mt)
  for _, l in ipairs(t) do set[l] = true end
  return set
end

--[[--
Set.contains = function (self, value)

  Does the set contain this value?

  @Parameter: key
    The value to look for in our set

  return self[value]
end

Set.tostring = function (self, value)

  Convert a set to a string representation
  Taken from: http://www.lua.org/pil/13.1.html


  local s = "{"
  local sep = ""
  for e in pairs(self) do
    s = s .. sep .. e
    sep = ", "
  end
  return s .. "}"
end

return _M;
--]]--