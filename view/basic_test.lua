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
local Basic = require("view/basic")

module("view_basic_textcase", lunit.testcase, package.seeall)


local WIDTH = 160
local HEIGHT = 160


function view_test()
	local sheet = Sheet:new()

	sheet:insertCell(1, "A1")
	sheet:insertCell(2, "A2")
	sheet:insertCell(3, "A3")
	sheet:insertCell(4, "A4")
	sheet:insertCell("sum(A1:A4)=", "A5")
	sheet:setCursor("A6")

	local img = ui.createImage(WIDTH, HEIGHT)
	local context = img:getContext()

	local view = Basic:new(sheet, context, WIDTH, HEIGHT)
	view:event({ type = "keypress", key = "5+" })
	view:draw()

	local ref = ui.createFromPng("view/basic-001.png")

	if img ~= ref then
		img:writePng("view/basic-001-fail.png")
	end
	assert_equal(img, ref)
end


function event_test()
	local sheet = Sheet:new()
	local img = ui.createImage(WIDTH, HEIGHT)

	local view = Basic:new(sheet, context, WIDTH, HEIGHT)

	view:event({ type = "keypress", key = "1" })
	assert_equal("1", table.concat(view.textinput))

	view:event({ type = "keypress", key = "+" })
	assert_equal("1+", table.concat(view.textinput))

	view:event({ type = "keypress", key = "rand(" })
	assert_equal("1+rand(", table.concat(view.textinput))

	view:event({ type = "keypress", key = "<delete>" })
	assert_equal("1+", table.concat(view.textinput))
end
