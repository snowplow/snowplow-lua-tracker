package.path = '../lib/?.lua;' .. '../lib/snowplow/?.lua;' .. package.path

local snowplow = require('snowplow.snowplow')

tracker = snowplow.newTrackerForCf( "dbdbdb" )
tracker:setPlatform ( "pc" )
tracker:trackScreenView( "Game HUD", "23" )