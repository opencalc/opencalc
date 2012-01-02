--[[
opencalc - an open source calculator

Copyright (C) 2011  Richard Titmuss <richard@opencalc.me>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program in the file COPYING; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
--]]

require "lunit"

require "builtin-functions"
require "builtin-units"
local Sheet = require "sheet"

module("parser_infix_textcase", lunit.testcase, package.seeall)


local tests = {
	-- number
	["1234"] = 1234,
	["-1234"] = -1234,
	["+1234"] = 1234,
	["1234.5678"] = 1234.5678,
	["-1234.5678"] = -1234.5678,
	["1234e2"] = mp.new("1234e2"),
	["1234e-2"] = mp.new("1234e-2"),
	["1234e+2"] = mp.new("1234e+2"),
	["-1234.5678e2"] = mp.new("-1234.5678e2"),
	["-1234.5678e-2"] = mp.new("-1234.5678e-2"),

	-- cell address
	["A4"] = "!err",
	["AA44"] = "!err",
 
	-- cell range
	["B1:B3sum "] = 6,
	[" B1:B3 sum "] = 6,

	-- function no args
	["\207\128"] = mp.pi(), -- pi

	-- function 1 args
	["3sin"] = mp.sin(mp.new(3)),
	["3 sin"] = mp.sin(mp.new(3)),
	["(3+3)sin"] = mp.sin(mp.new(6)),
	["(2*3+4)sin"] = mp.sin(mp.new(10)),
	["(2+3*4)sin"] = mp.sin(mp.new(14)),

	["3 sin + 1"] = mp.sin(mp.new(3)) + mp.new(1),
	["1 + 3 sin"] = mp.new(1) + mp.sin(mp.new(3)),
	["3 sin / 1"] = mp.sin(mp.new(3)) / mp.new(1),
	["1 / 3 sin"] = mp.new(1) / mp.sin(mp.new(3)),

--	["3 sin sin"] = mp.sin(mp.new(3)),

	-- function 2 args
	["2^3"] = mp.pow(mp.new(2), mp.new(3)),
	["(1+1)^(2+1)"] = mp.pow(mp.new(2), mp.new(3)),

	["2^3 + 1"] = mp.pow(mp.new(2), mp.new(3)) + mp.new(1),
	["1 + 2^3"] = mp.new(1) + mp.pow(mp.new(2), mp.new(3)),
	["2^3 / 1"] = mp.pow(mp.new(2), mp.new(3)) / mp.new(1),
	["1 / 2^3"] = mp.new(1) / mp.pow(mp.new(2), mp.new(3)),

	["1 ^ 2 ^ 3"] = mp.pow(mp.pow(mp.new(1), mp.new(2)), mp.new(3)),

	-- factors ops
	["1+1"] = 2,
	[" 1 + 1  "] = 2,
	["-125e-2+B1"] = mp.new("-025e-2"),
	["-125e-2-B1"] = mp.new("-225e-2"),
	["B2+B3"] = 5,

	-- terms ops
	["-125e-2*B2"] = mp.new("-125e-2") * mp.new(2),
	["-125e-2/B2"] = mp.new("-125e-2") / mp.new(2),
	["B2*B3"] = 6,

	-- equations
	["\207\128*-125e-2/B2"] = mp.pi() * mp.new("-125e-2") / mp.new(2),
	["3 + 5*9 / (1+1) - 12"] = 13.5,
	["3 + 5*9 / (1+1) - B2"] = 23.5,
	["3 + 5*9 / (B2 cos) - B3"] = mp.new("-1.081349082775071366314e+02"),
--	["1 / 2 * 3"] = 1.5,
}


function parser_test()
	sheet = Sheet:new()

	sheet:insertCell("1", "B1")
	sheet:insertCell("2", "B2")
	sheet:insertCell("3", "B3")

	for f,v in pairs(tests) do
		if v ~= false then
			f = string.gsub(f, "/", "\195\183")
			f = string.gsub(f, "*", "\195\151")

			--print("testing:", f)
			sheet:insertCell(f, "A1")
			if type(v) == "number" then
				v = mp.new(v)
			end
			assert_equal(v, sheet:getCell("A1"):value(), f)
		end
	end
end
