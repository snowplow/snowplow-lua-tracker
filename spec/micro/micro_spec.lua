local micro = require("spec.micro.micro")
local snowplow = require("snowplow")

describe("micro", function()
  before_each(micro.clear_cache)

  it("clears the cache", function()
    local t = snowplow.new_tracker(micro.get_url())
    for _ = 1, 20 do
      local ok, err = t:track_struct_event("category", "action")
      assert.is_true(ok)
      assert.is_nil(err)
    end

    assert.is_equal(20, #micro.get_good_events())
    micro.clear_cache()
    assert.is_equal(0, #micro.get_good_events())
  end)

  it("can get all events from /good with no filter)", function()
    local t = snowplow.new_tracker(micro.get_url())
    for _ = 1, 20 do
      local ok, err = t:track_struct_event("category", "action")
      assert.is_true(ok)
      assert.is_nil(err)
    end

    local data = micro.get_good_events()
    assert.is_equal(20, #data)
  end)

  it("can get an event from /good using a filter", function()
    local t = snowplow.new_tracker(micro.get_url())

    local ok, err = t:track_struct_event("filtered_out_event", "filtered_out_event")
    assert.is_true(ok)
    assert.is_nil(err)

    ok, err = t:track_struct_event("test_category", "test_action")
    assert.is_true(ok)
    assert.is_nil(err)

    local data = micro.get_good_events({
      ["limit"] = 1,
    })

    assert.is_equal("test_category", data[1]["event"]["se_category"])
    assert.is_equal("test_action", data[1]["event"]["se_action"])
  end)
end)
