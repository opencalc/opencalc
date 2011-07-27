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

local Sheet = require "sheet"

module("parser_toy_textcase", lunit.testcase, package.seeall)


function func_test()
	sheet = Sheet:new()

	sheet:insertCell("=A2", "A1")
	assert_equal("!err", sheet:getCell("A1"):value())

	sheet:insertCell("=1+1", "A1")
	assert_equal(2, sheet:getCell("A1"):value())

	sheet:insertCell(" = 1 + 1", "A1")
	assert_equal(2, sheet:getCell("A1"):value())

	sheet:insertCell("1+1=", "A1")
	assert_equal(2, sheet:getCell("A1"):value())

	sheet:insertCell("1 + 1 = ", "A1")
	assert_equal(2, sheet:getCell("A1"):value())

	sheet:insertCell("sin(1)= ", "A1")
	assert_equal(math.sin(1), sheet:getCell("A1"):value())

	sheet:insertCell("cos(1)= ", "A1")
	assert_equal(math.cos(1), sheet:getCell("A1"):value())

	sheet:insertCell("tan(1)= ", "A1")
	assert_equal(math.tan(1), sheet:getCell("A1"):value())

	sheet:insertCell("rand()= ", "A1")
	local x = sheet:getCell("A1"):value()
	assert_equal(x, sheet:getCell("A1"):value())

	sheet:recalculate()
	assert_not_equal(x, sheet:getCell("A1"):value())

	sheet:insertCell("1", "B1")
	sheet:insertCell("2", "B2")
	sheet:insertCell("3", "B3")
	sheet:insertCell("sum(B1:B3)=", "B4")
	assert_equal(6, sheet:getCell("B4"):value())
end


function crash_test()
	assert_pass(function()
		sheet:insertCell("+=", "A1")
	end)
end
