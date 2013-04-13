package.path = '../lib/?.lua;' .. '../lib/snowplow/?.lua;' .. package.path

local snowplow = require('snowplow.tracker')

snowplow.trackScreenView("Game HUD", 23)