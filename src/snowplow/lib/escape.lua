--- escape.lua
--
-- Copyright (c) 2013 Snowplow Analytics Ltd. All rights reserved.
--
-- This program is licensed to you under the Apache License Version 2.0,
-- and you may not use this file except in compliance with the Apache License Version 2.0.
-- You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the Apache License Version 2.0 is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.
--
-- Authors:     Alex Dean
-- Copyright:   Copyright (c) 2013 Snowplow Analytics Ltd
-- License:     Apache License Version 2.0

local escape = {}

-- --------------------------------------------------------------
-- Static methods

escape.escapeUri = function (s)
  --[[--
  Escapes a URI (or URI fragment). Example:
  escape.escapeUri("John Smith") => "John%20Smith"
  
  Source: https://github.com/radare/luvit-Connect/blob/master/modules/querystring.lua
  
  @Parameter: s
    The string to escape
  --]]--

  s = string.gsub( s, "\n", "\r\n" )
  s = string.gsub( s, "([^0-9a-zA-Z ])", -- Locale independent
        function (c) return string.format ("%%%02X", string.byte(c)) end)
  s = string.gsub( s, " ", "+")
  
  return s
end

-- --------------------------------------------------------------

return escape