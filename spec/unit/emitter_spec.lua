--- emitter_spec.lua
--
-- Copyright (c) 2013 - 2022 Snowplow Analytics Ltd. All rights reserved.
--
-- This program is licensed to you under the Apache License Version 2.0,
-- and you may not use this file except in compliance with the Apache License Version 2.0.
-- You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the Apache License Version 2.0 is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.

local emitter = require("emitter")

describe("emitter", function()
  it("can be created with default settings", function()
    local e = emitter.new("test.invalid")
    assert.is_equal("https://test.invalid/com.snowplowanalytics.snowplow/tp2", e:get_collector_url())
    assert.is_equal("POST", e:get_request_method())
  end)

  it("can be created with custom settings", function()
    local e = emitter.new("http://test.invalid", "GET")
    assert.is_equal("http://test.invalid/i", e:get_collector_url())
    assert.is_equal("GET", e:get_request_method())
  end)
end)
