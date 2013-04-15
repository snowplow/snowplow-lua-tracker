--- escape-test.lua
--
-- Copyright (c) 2013 SnowPlow Analytics Ltd. All rights reserved.
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
-- Copyright:   Copyright (c) 2013 SnowPlow Analytics Ltd
-- License:     Apache License Version 2.0

local escape = require( "lib.escape" )

describe("escape.escapeUri should URI-escape strings correctly", function()
  assert.are.equal(escape.escapeUri("JohnSmith"), "JohnSmith")
  assert.are.equal(escape.escapeUri("john+smith"), "john+smith"))
  assert.are.equal(escape.escapeUri("John Smith"), "John%20Smith")
end)
