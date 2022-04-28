-- Ignore files copied from GitHub and directories present in GitHub Actions that contain lua files
exclude_files = {
    ".luarocks",
    ".install",
    "src/snowplow/lib/json.lua",
}

-- Ignore the _TEST global
read_globals = {
    "_TEST",
}