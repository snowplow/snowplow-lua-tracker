function track_struct_event(category, action, label, property, value)
  --[[--
  Sends a custom structured event to SnowPlow.

  @Parameter: category
    The name you supply for the group of
    objects you want to track
  @Parameter: action
    A string that is uniquely paired with each
    category, and commonly used to define the
    type of user interaction for the object
  @Parameter: label
    An optional string to provide additional
    dimensions to the event data
  @Parameter: property
    An optional string describing the object
    or the action performed on it. This might
    be the quantity of an item added to basket
  @Parameter: value
    A value that you can use to provide
    numerical data about the user event
  --]]--

  -- Type and value checks
  assert(type(category) == "string" and category ~= nil and category <> "", "category is required and must be a string")
  assert(type(action) == "string", "action is required and must be a string")
  assert(type(label) == "string", "label must be a string or nil")
  assert(type(property) == "string", "property must be a string or nil")
  assert(type(value) == "number", "value must be a number or nil")

  -- Now let's build the table
  pairs = {
    {"e", "se"},
    {"ev_ca", category},
    {"ev_ac", action},
    {"ev_la", label},
    {"ev_pr", property},
    {"ev_va", numeric_value}
  } 

  -- Finally call track
  track(pairs)
end

function track(event_pairs)
  --[[--
  Tracks any given SnowPlow event, by sending the specific
  event_pairs to the SnowPlow collector.

  @Parameter: event_pairs
    A table containing all of the name-value pairs
    to be tracked as part of this event
  --]]--

  -- TODO
end
