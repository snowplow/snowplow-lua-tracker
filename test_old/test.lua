package.path = '../lib/?.lua;' .. '../lib/snowplow/?.lua;' .. package.path

local snowplow = require('snowplow.snowplow')

tracker = snowplow.newTrackerForCf( "d3rkrsqld9gmqf" )
tracker:encodeBase64( false )
tracker:platform ( "tv" )
tracker:trackScreenView( "Game HUD", "23" )

tracker2 = snowplow.newTrackerForCf( "d3rkrsqld9gmqf" )
tracker2:encodeBase64( false )
tracker2:platform ( "iot" )
tracker2:trackScreenView( "Test", "23" )

print(tracker.config.platform)
tracker:trackScreenView( "Game HUD", "23" )