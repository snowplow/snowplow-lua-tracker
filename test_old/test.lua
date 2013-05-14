package.path = '../lib/?.lua;' .. '../lib/snowplow/?.lua;' .. package.path

local snowplow = require('snowplow.snowplow')

local tracker = snowplow.newTrackerForCf( "d3rkrsqld9gmqf" )
tracker:encodeBase64( false )
tracker:platform ( "tv" )
tracker:trackScreenView( "Game HUD", "23" )
tracker:trackUnstructEvent( "save-game", { save_id = 23 }, 23.232312 )

local tracker2 = snowplow.newTrackerForUri( "cc-endpoint2.beanstalky.com" )
tracker2:encodeBase64( false )
tracker2:platform( "iot" )
tracker2:setColorDepth( 32 )
tracker2:trackScreenView( "Test", "23" )

tracker:trackScreenView( "Game HUD", "23" )