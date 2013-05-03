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

local payload = require("payload")
local validate = require("validate")

describe("payload", function()

  it("should correctly assemble a payload", function()

    local pb = payload.newPayloadBuilder( true )
    pb.addRaw( "e", "sv" )
    pb.add( "sv_na", "Welcome" )
    pb.add( "sv_id", "231", validate.isStringOrNil )
    
    assert.are.equal(pb.build(), "?e=sv&sv_na=Welcome&sv_id=231")
  end)

  it("should correctly assemble another payload", function()

    local pb = payload.newPayloadBuilder( false )
    pb.addRaw( "e", "hello" )
    pb.addRaw( "hello_test", "test")
    
    pb.add( "ev_ca", "2  spaces", validate.isNonEmptyString )
    pb.add( "ev_va", -23.34, validate.isNumberOrNil )

    assert.are.equal(pb.build(), "?e=hello&hello_test=test&ev_ca=2++spaces&ev_va=%2D23%2E34")
  end)

  it("should error when a validation on an add() fails", function()

    local pb = payload.newPayloadBuilder( true )
    local f = function()
      pb.add( "num", -2, validate.isPositiveInteger )
    end

    assert.has_error(f, "num is required and must be a positive integer, not [-2]")
  end)

  it("should error when a validation on an addRaw() fails", function()

    local pb = payload.newPayloadBuilder( false )
    pb.add( "ev_la", nil, validate.isStringOrNil )
    local f = function()
      pb.addRaw( "flag", "falsy", validate.isBoolean )
    end

    assert.has_error(f, "flag is required and must be a boolean, not [falsy]")
  end)

end)
