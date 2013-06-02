--- bad1_spec.lua
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

local snowplow = require("snowplow")

describe("Integration tests with bad config", function()

  it("should throw an error on a bad configuration option", function()

    local t = snowplow.newTrackerForCf( "d3rkrsqld9gmqf" )
    t:encodeBase64( false )
    t:platform( "tv" )

    local f = function() t:setColorDepth("unknown") end
    assert.has_error(f, "depth is required and must be a positive integer, not [unknown]")
  end)

  it("should throw an error without impacting another tracker", function()

    local t1 = snowplow.newTrackerForCf( "d3rkrsqld9gmqf" )
    t1:platform( "tv" )
    assert.has_no.errors( function() t1:trackScreenView( "Game HUD", "23" ) end )
    assert.has_no.errors( function() t1:trackUnstructEvent( "save-game", { save_id = 23 }, 1369330092 ) end )

    local t2 = snowplow.newTrackerForUri( "cc-endpoint2.beanstalky.com" )
    t2:encodeBase64( false )
    t2:platform( "iot" )
    t2:setColorDepth( 32 )
    t2:setViewport( 1028, 760 )

    local f = function() t2:setUserId( true ) end
    assert.has_error(f, "userId is required and must be a non-empty string, not [true]")

    t1:platform( "iot" ) -- Redefine
    t1:encodeBase64( false ) -- Redefine
    assert.has_no.errors( function() t1:trackScreenView( "Test", "23" ) end )
    assert.has_no.errors( function() t1:trackStructEvent( "hud", "save", nil, nil, nil, 1368725287 ) end )

  end)

  it("should be reusable if the error is caught", function()

    local t1 = snowplow.newTrackerForCf( "d3rkrsqld9gmqf" )
    t1:encodeBase64( false )
    status, err = pcall( t1.platform, t1, false )
    assert.are.equal( status, false )
    assert.are.equal( err, "lib/snowplow/validate.lua:73: platform must be a string from the set {pc, mob, cnsl, tv, iot}, not [false]" )

    assert.has_no.errors( function() t1:platform( "cnsl" ) end )
    assert.has_no.errors( function() t1:trackScreenView( "Test", "23", 1368725287 ) end )

  end)

end)