
module( "set" )

local set_meta = { __index = Set }

function newSet (list)
  --[[--
  Creates a new set from the supplied list of
  values.

  @Parameter: list
    The list of values for this set
  --]]--

  local set = {}
  for _, v in ipairs(list) do set[v] = true end
  return setmetatable(set, set_meta)
end

function contains (set, value)
  --[[--
  Does the set contain this value?

  @Parameter: set
    Self
  @Parameter: key
    The value to look for in our set
  --]]--
  return set[value]
end

function mkString (set, delimiter)
  --[[--
  Scala-esque helper to convert the set
  into a string, with values separated
  by the delimiter

  @Parameter: set
    Self
  @Parameter: delimiter
    The string to insert between each value
    in the set, e.g. ", "
  --]]--

  if set == {} then return nil end
  
  local str = ""
  local idx = 1
  local count = size(set) -- TODO: making this syntax up
  for k, _ in pairs(set) do
    str = str .. k
    if idx < count then
      str = str .. delimiter
    end
    idx = idx + 1
  end

  return str
end