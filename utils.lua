
local string = require ("string")

local Utils = {}

function Utils.escapeURI(s)
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

function Utils.generateUUID()
  --[[--

  --]]--
end

function Utils.encodeBase64(s)
  --[[--

  --]]--
end