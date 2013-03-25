
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

  -- Check category is set
  if category ~= nil or category == "" then
    -- Throw an error?
  end

  -- Check action is set
  if action ~= nil or action == "" then
    -- Throw an error?
  end

  -- Now check that value is numeric
  -- TODO

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

function track(event_pairs, mock)
  --[[--
  Tracks any SnowPlow event, by sending the event_pairs
  to the SnowPlow collector.

  @Parameter: event_pairs
    A table containing all of the name-value pairs
    to be tracked as part of this event
  @Parameter: mock
    If mock is set, then rather than making an actual HTTP GET,
    track() simply returns the full URL which should have been GETted.
  --]]--

  -- TODO
end