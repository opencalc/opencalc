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
require "view/lunit"

module("menu_textcase", lunit.testcase, package.seeall)

local ui = require("ui")

local Menu = require("input.menu")
local Sheet = require("sheet")


function newMenu()
	local sheet = Sheet:new()

	local items = {
		title = "Title",
		order = "promote",
		{ "Size", "font_size", { 8, 10, 12, 14 }, def = 10 },
		{ "Hidden", hidden=true },
		{ "Submenu", submenu = {
			{ "Red" },
			{ "Green" },
			{ "Blue" },
		}},
		{ function(sheet) return "One" end },
		{ "Two" },
		{ "Three" },
		{ "Four" },
		{ "Five" },
		{ "Six" },
		{ "Seven" },
		{ "Eight" },
		{ "Nine" },
		{ "Ten" },
	}

	return Menu:new(sheet, items)
end


function menu_test()
	local menu = newMenu()

	assert_view_image("menu-001.png", menu)

	assert_false(menu:event({ type = "keypress", key = "<left>" }))
end

function selection_test()
	local menu = newMenu()

	menu:event({ type = "keypress", key = "<right>" })
	menu:event({ type = "keypress", key = "<right>" })
	assert_view_image("menu-002.png", menu)
end

function typeahead_test()
	local menu = newMenu()

	menu:event({ type = "keypress", key = "t" })
	assert_view_image("menu-003.png", menu)

	menu:event({ type = "keypress", key = "w" })
	assert_view_image("menu-004.png", menu)

	menu:event({ type = "keypress", key = "<delete>" })
	assert_view_image("menu-003.png", menu)
end

function promote_test()
	local menu = newMenu()

	assert_not_equal("Four", menu.items[1][1])

	menu:event({ type = "keypress", key = "four" })
	menu:event({ type = "keypress", key = "=" })

	assert_equal("Four", menu.items[1][1])
end


function scroll_test()
	local menu = newMenu()

	menu.selected = 1
	assert_view_image("menu-001.png", menu)

	menu.selected = 3
	assert_view_image("menu-006.png", menu)

	menu.selected = #menu.filtered - 3
	assert_view_image("menu-007.png", menu)

	menu.selected = #menu.filtered
	assert_view_image("menu-008.png", menu)
end



function hidden_test()
	local menu = newMenu()
	assert_equal(12, #menu.filtered)

	menu.items[2].hidden = false
	menu:event({ type = "keypress", key = "<delete>" })
	assert_equal(13, #menu.filtered)
end
