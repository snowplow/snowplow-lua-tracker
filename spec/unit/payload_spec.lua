--- payload_spec.lua
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

local payload = require("lib.snowplow.payload")
local validate = require("lib.snowplow.validate")

describe("payload", function()

  it("should correctly assemble a payload", function()

    local pb = payload.newPayloadBuilder( self.config.encodeBase64 )
    pb.addRaw( "e", "sv" )
    pb.add( "sv_na", "Welcome" )
    pb.add( "sv_id", "231", validate.isStringOrNil )
    
    assert.are.equal(pb.build(), "?arg")
  end)

  it("should correctly assemble a second payload", function()

    local pb = payload.newPayloadBuilder( self.config.encodeBase64 )
    pb.addRaw( "e", "hello" )
    pb.addRaw( "hello_test", "test")
    
    pb.add( "ev_ca", "2  spaces", validate.isNonEmptyString )
    pb.add( "ev_va", -23.34, validate.isNumberOrNil )

    assert.are.equal(pb.build(), "?arg")
  end)

  pending("should error when a validation fails")
  -- TODO: write this.

end)