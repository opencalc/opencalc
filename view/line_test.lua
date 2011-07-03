--[[
opencalc - an open source calcualtor

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

local ui = require("ui")

local Sheet = require("sheet")
local Line = require("view/line")

module("view_line_textcase", lunit.testcase, package.seeall)


local WIDTH = 160
local HEIGHT = 160


function view_test()
	local sheet = Sheet:new()

	for i = 1,10 do
		sheet:insertCell(i-1, "A"..i)
		sheet:insertCell("(A"..i.."^2)-6=", "B"..i)
	end

	sheet:dump()

	local img = ui.createImage(WIDTH, HEIGHT)
	local context = img:getContext()

	local view = Line:new(sheet, context, WIDTH, HEIGHT)
	view:draw({ "5", "+" })

	local ref = ui.createFromPng("view/line-001.png")

	if img ~= ref then
		img:writePng("view/line-001-fail.png")
	end
	assert_equal(img, ref)
end
