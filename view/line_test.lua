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
require "view/lunit"

module("view_line_textcase", lunit.testcase, package.seeall)

local ui = require("ui")

local Sheet = require("sheet")
local Line = require("view/line")


function view_test()
	local sheet = Sheet:new()

	for i = 1,10 do
		sheet:insertCell(i-1, "A"..i)
		sheet:insertCell("(A"..i.."^2)-6=", "B"..i)
	end

	local view = Line:new(sheet, "view1")
	assert_view_image("line-001.png", view)
end
