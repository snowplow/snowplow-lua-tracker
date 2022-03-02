--- validate_spec.lua
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

local validate = require("validate")
local set = require("lib.set")
local ss = require("lib.utils").safe_string -- Alias

local field_name = "TestField"

local function assert_data_table(data_table, validator)
  for i, t in ipairs(data_table) do
    local f = function()
      validator(field_name, t[1])
    end

    if i > 1 then -- Skip header row
      if t[2] == nil then
        assert.has_no.errors(f)
      else
        assert.has_error(f, t[2])
      end
    end
  end
end

describe("validate", function()
  it("is_boolean() should validate correctly", function()
    local err = function(value)
      return field_name .. " is required and must be a boolean, not [" .. ss(value) .. "]"
    end

    local data_table = {
      { "INPUT", "EXPECTED" },
      { true, nil },
      { false, nil },
      { 23, err(23) },
      { "hello", err("hello") },
    }

    assert_data_table(data_table, validate.is_boolean)
  end)

  it("is_non_empty_table() should validate correctly", function()
    local err = function(value)
      return field_name .. " is required and must be a non-empty table, not [" .. ss(value) .. "]"
    end

    local data_table = {
      { "INPUT", "EXPECTED" },
      { { "hello" }, nil },
      { { 1, 2 }, nil },
      { { a = 1, b = "c" }, nil },
      { { a = true, b = false }, nil },
      { nil, err("<nil>") },
      { {}, err("{}") },
      { "hello", err("hello") },
      { 23.3, err(23.3) },
    }

    assert_data_table(data_table, validate.is_non_empty_table)
  end)

  it("is_table_or_nil() should validate correctly", function()
    local err = function(value)
      return field_name .. " must be a table or nil, not [" .. ss(value) .. "]"
    end

    local data_table = {
      { "INPUT", "EXPECTED" },
      { { "hello" }, nil },
      { { 1, 2 }, nil },
      { { a = 1, b = "c" }, nil },
      { { a = true, b = false }, nil },
      { nil, nil }, -- Difference from the above
      { {}, nil }, -- Difference from the above
      { "hello", err("hello") },
      { 23.3, err(23.3) },
    }

    assert_data_table(data_table, validate.is_table_or_nil)
  end)

  it("is_non_empty_string() should validate correctly", function()
    local err = function(value)
      return field_name .. " is required and must be a non-empty string, not [" .. ss(value) .. "]"
    end

    local data_table = {
      { "INPUT", "EXPECTED" },
      { "a string", nil },
      { "another", nil },
      { "", err("") },
      { nil, err("<nil>") },
      { {}, err("{}") },
      { { a = 1, b = "c" }, err("<table>") },
      { 23.3, err(23.3) },
    }

    assert_data_table(data_table, validate.is_non_empty_string)
  end)

  it("is_string_or_nil() should validate correctly", function()
    local err = function(value)
      return field_name .. " must be a string or nil, not [" .. ss(value) .. "]"
    end

    local data_table = {
      { "INPUT", "EXPECTED" },
      { "a string", nil },
      { "another", nil },
      { "", nil }, -- Difference from the above
      { nil, nil }, -- Difference from the above
      { {}, err("{}") },
      { { a = 1, b = "c" }, err("<table>") },
      { 23.3, err(23.3) },
    }

    assert_data_table(data_table, validate.is_string_or_nil)
  end)

  it("is_string_from_set() should validate correctly", function()
    local s = set.new_set({ "a", "c", "f" })

    local err = function(value)
      return field_name .. " must be a string from the set " .. s:to_string() .. ", not [" .. ss(value) .. "]"
    end

    local set_validator = function(name, value)
      return validate.is_string_from_set(s, name, value)
    end

    local data_table = {
      { "INPUT", "EXPECTED" },
      { "a", nil },
      { "f", nil },
      { "g", err("g") },
      { "hello", err("hello") },
      { "", err("") },
      { nil, err("<nil>") },
      { {}, err("{}") },
      { { a = 1, b = "c" }, err("<table>") },
      { 23.3, err(23.3) },
    }

    assert_data_table(data_table, set_validator)
  end)

  it("is_number() should validate correctly", function()
    local err = function(value)
      return field_name .. " is required and must be a number, not [" .. ss(value) .. "]"
    end

    local data_table = {
      { "INPUT", "EXPECTED" },
      { 23, nil },
      { 0, nil },
      { -10.586, nil },
      { 4523000.29, nil },
      { nil, err("<nil>") },
      { "hello", err("hello") },
      { { a = 1, b = "c" }, err("<table>") },
    }

    assert_data_table(data_table, validate.is_number)
  end)

  it("is_number_or_nil() should validate correctly", function()
    local err = function(value)
      return field_name .. " must be a number or nil, not [" .. ss(value) .. "]"
    end

    local data_table = {
      { "INPUT", "EXPECTED" },
      { 23, nil },
      { 0, nil },
      { -10.586, nil },
      { 4523000.29, nil },
      { nil, nil }, -- Only difference from the above
      { "hello", err("hello") },
      { { a = 1, b = "c" }, err("<table>") },
    }

    assert_data_table(data_table, validate.is_number_or_nil)
  end)

  it("is_positive_integer() should validate correctly", function()
    local err = function(value)
      return field_name .. " is required and must be a positive integer, not [" .. ss(value) .. "]"
    end

    local data_table = {
      { "INPUT", "EXPECTED" },
      { 23, nil },
      { 0, nil },
      { 452300.29, err("452300.29") },
      { -1, err("-1") },
      { -10.586, err("-10.586") },
      { nil, err("<nil>") },
      { "hello", err("hello") },
      { { a = 1, b = "c" }, err("<table>") },
    }

    assert_data_table(data_table, validate.is_positive_integer)
  end)
end)
