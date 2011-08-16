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
local Sheet = require "sheet"

module("parser_infix_textcase", lunit.testcase, package.seeall)


local eqtests = {
	["1+1"] = 2,
	[" 1 + 1  "] = 2,
	["1sin"] = mp.sin(mp.new(1)),
	["1cos "] = mp.cos(mp.new(1)),
	["1tan "] = mp.tan(mp.new(1)),
	["2^3 "] = mp.pow(mp.new(2),mp.new(3)),

}


function eq_test()
	sheet = Sheet:new()

	for f,v in pairs(eqtests) do
		sheet:insertCell(f, "A1")
		if type(v) == "number" then
			v = mp.new(v)
		end
		assert_equal(v, sheet:getCell("A1"):value(), f)
	end
end


function err_test()
	sheet = Sheet:new()

	sheet:insertCell("A2", "A1")
	assert_equal("!err", sheet:getCell("A1"):value())
end


function function_test()
	sheet = Sheet:new()

	sheet:insertCell("rand ", "A1")
	local x = sheet:getCell("A1"):value()

	sheet:recalculate()
	assert_not_equal(x, sheet:getCell("A1"):value())

	sheet:insertCell("1", "B1")
	sheet:insertCell("2", "B2")
	sheet:insertCell("3", "B3")
	sheet:insertCell("B1:B3sum", "B4")
	assert_equal(mp.new(6), sheet:getCell("B4"):value())
end
