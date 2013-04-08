
-- TODO: how to only import a single library into a module?
local string = require ("string")

module(...)

local Set = {}

-- -------------------------------
-- A simple Lua set

local set_meta = { __index = Set }
function newSet (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return setmetatable(set, set_meta)
end

function Set.contains (set, key)
  return set[key]
end

function Set.mkString (set, delim)
  return "TODO"
end

function escapeURI (s)
  --[[--
  Escapes a URI (or URI fragment). Example:
  Utils.escapeURI("John Smith") => "John%20Smith"
  Source: https://github.com/radare/luvit-Connect/blob/master/modules/querystring.lua
  
  @Parameter: s
    The string to escape
  --]]--

  s = string.gsub (s, "\n", "\r\n")
  s = string.gsub (s, "([^0-9a-zA-Z ])", -- locale independent
  function (c) return string.format ("%%%02X", string.byte(c)) end)
  s = string.gsub (s, " ", "+")
  return s
end

function generateUUID ()
  --[[--

  --]]--
end

function encodeBase64 (s)
  --[[--

  --]]--
end
