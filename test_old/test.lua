package.path = '../lib/?.lua;' .. '../lib/snowplow/?.lua;' .. package.path

local snowplow = require('snowplow.snowplow')

tracker = snowplow.newTrackerForCf( "d3rkrsqld9gmqf" )
tracker:encodeBase64( false )
tracker:platform ( "pc" )
tracker:trackScreenView( "Game HUD", "23" )
