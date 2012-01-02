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

module("plugin_testcase", lunit.testcase, package.seeall)

local Plugin = require "plugin"
local Sheet = require "sheet"

require("builtin-functions")
require("builtin-units")

local deltalimit = mp.new("1e-8")


function lunit.assert_lessthan(expected, actual, msg)
	stats.assertions = stats.assertions + 1
	if expected >= actual then
		failure( "assert_lessthan", msg, "expected %s but was %s", format_arg(expected), format_arg(actual) )
	end
	return actual
end
--lunit.traceback_hide( lunit.assert_lessthan )


function check(name, testlist)
	for i,test in ipairs(testlist) do
		if test == "TODO" then
			print("TODO test:", name)
			return
		end

		local eq,r = string.match(test, "(.+) == (.+)")

		sheet = Sheet:new()
		sheet:insertCell(eq, "A1")
		sheet:insertCell(r, "A2")

		local eq_cell = sheet:getCell("A1"):value()
		local r_cell = sheet:getCell("A2"):value()

		print(test, ":", eq_cell, r_cell)

		local delta = mp.abs(mp.sub(
			r_cell, eq_cell
		))

		assert_lessthan(delta, deltalimit, test)
		assert_equal(eq_cell:unit(), r_cell:unit())
	end
end

-- plugin dynamically creates tests
