--- mock_os.lua
--
-- Copyright (c) 2022 Snowplow Analytics Ltd. All rights reserved.
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
-- Authors:     Greg Leonard
-- Copyright:   Copyright (c) 2022 Snowplow Analytics Ltd
-- License:     Apache License Version 2.0

local mock_os = {}

-- --------------------------------------------------------------

-- Gives our mock all the same methods as the real 'os' module
setmetatable(mock_os, os)

-- Mock os.time with a known value
-- @return number: a known mock time
mock_os.time = function()
  return 1000000000000
end

-- --------------------------------------------------------------

return mock_os
