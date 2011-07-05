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


local ui = require("ui")

local WIDTH = 160
local HEIGHT = 160


function assert_view_image(file, view)
	local img = ui.createImage(WIDTH, HEIGHT)
	local context = img:getContext()

	view:draw(context, WIDTH, HEIGHT)

	file = "screenshots/" .. file
	local ref = ui.createFromPng(file)

	if img ~= ref then
		file = string.gsub(file, ".png", "-fail.png")
		img:writePng(file)
	end
	assert_equal(img, ref, "Failed screenshot: " .. file)
end
