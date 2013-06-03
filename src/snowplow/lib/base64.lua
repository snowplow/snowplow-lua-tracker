--- base64.lua
--
-- https://gist.github.com/2563975
--
-- V0.3 for Lua 5.1
--
-- A simple Base64 encoder/decoder that uses a URL safe variant of the standard.
-- This implementation encodes character 62 as '-' (instead of '+') and character 63 as '_' (instead of '/').
-- In addition, padding is not used by default.
-- A full description of the specification can be found here: http://tools.ietf.org/html/rfc4648
--
-- To encode, use base64.encode(input), where input is a string of arbitrary bytes.  The output is a Base64 encoded string.
-- To decode, use base64.decode(input), where input is a Base64 encoded string.  The output is a string of arbitrary bytes.
--
-- The library will throw an error on invalid input, you can catch these as such:
--
-- local status, result = pcall(base64.decode(invalidInput))
-- if not status then
--     print("Error, "..result)
-- end
--
-- If you prefer a different Base64 variant, you can simply change the ENCODABET to your liking.
-- If you wish to use padding, you can change the PAD value to a non-nil, non-empty string.
-- The library will still be able to decode non-padded strings if a PAD is given.
--
-- For all valid input, input == base64.decode(base64.encode(input)).
--
-- This library has a dependency on LuaBit v0.4, which can be found here: http://luaforge.net/projects/bit/
--
-- Copyright (C) 2012 by Paul Moore
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

require "lib.bit"

base64 = {}
 
--- octet -> char encoding.
local ENCODABET = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
	'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
	'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
	'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
	'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
	'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '-', '_'
}
 
--- char -> octet encoding.
local DECODABET = {}
for i, v in ipairs(ENCODABET) do
	DECODABET[v] = i - 1
end
 
local PAD = nil
 
--- Converts a 6-bit octet into the associated Base64 character.
--
-- @param octet A 6-bit integer.
-- @return The Base64 representation of the character
local function toChar (octet)
	return assert(ENCODABET[octet + 1], "No Base64 character for octet: "..tostring(octet))
end
 
--- Converts a Base64 character into the associated octet.
--
-- @param char The single Base64 character.
-- @return The 6-bit integer representing the Base64 character.
local function toOctet (char)
	return assert(DECODABET[char], "Not a valid Base64 character: "..tostring(char))
end
 
--- Encodes a string into a Base64 string.
-- The input can be any string of arbitrary bytes.
-- If the input is not a string, or the string is empty, an error will be thrown.
--
-- @param input The input string.
-- @return The Base64 representation of the input string.
function base64.encode (input)
	
	assert(type(input) == "string", "Invalid input, expected type string but got: "..tostring(input).." as a: "..type(input))
	assert(#input > 0, "Invalid input, cannot encode an empty string.")
	
	local bytes = { input:byte(i, #input) }
 
	local out = {}
	
	-- Go through each triplet of 3 bytes, which produce 4 octets.
	local i = 1
	while i <= #bytes - 2 do
		local buffer = 0
		
		-- Fill the buffer with the bytes, producing a 24-bit integer.
		local b = bit.blshift(bytes[i], 16)
		b = bit.band(b, 0xff0000)
		buffer = bit.bor(buffer, b)
		
		b = bit.blshift(bytes[i + 1], 8)
		b = bit.band(b, 0xff00)
		buffer = bit.bor(buffer, b)
		
		b = bit.band(bytes[i + 2], 0xff)
		buffer = bit.bor(buffer, b)
		
		-- Read out the 4 octets into the output buffer.
		b = bit.blogic_rshift(buffer, 18)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		b = bit.blogic_rshift(buffer, 12)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		b = bit.blogic_rshift(buffer, 6)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		b = bit.band(buffer, 0x3f)
		out[#out + 1] = toChar(b)
				
		i = i + 3
	end
	
	-- Special case 1: One byte extra, will produce 2 octets.
	if #bytes % 3 == 1 then
		local buffer = bit.blshift(bytes[i], 16)
		buffer = bit.band(buffer, 0xff0000)
		
		local b = bit.blogic_rshift(buffer, 18)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		b = bit.blogic_rshift(buffer, 12)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		out[#out + 1] = PAD
		out[#out + 1] = PAD
		
	-- Special case 2: Two bytes extra, will produce 3 octets.
	elseif #bytes % 3 == 2 then
		local buffer = 0
		
		local b = bit.blshift(bytes[i], 16)
		b = bit.band(b, 0xff0000)
		buffer = bit.bor(buffer, b)
		
		b = bit.blshift(bytes[i + 1], 8)
		b = bit.band(b, 0xff00)
		buffer = bit.bor(buffer, b)
 
		b = bit.blogic_rshift(buffer, 18)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		b = bit.blogic_rshift(buffer, 12)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		b = bit.blogic_rshift(buffer, 6)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		out[#out + 1] = PAD
	end
	
	return table.concat(out)
	
end

return base64