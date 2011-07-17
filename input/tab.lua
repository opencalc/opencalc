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

module(..., package.seeall)


Tab = {}

local MARGIN = 13
local PADDING = 5
local FONT_SIZE = 14


function Tab:draw(context, width, height, title)
	context:setLineWidth(1)

	local y = (MARGIN / 2) + PADDING
	local x = MARGIN + PADDING

	-- title
	if title then
		local title = string.upper(title)

		context:selectFontSize(FONT_SIZE - 4)
		local te = context:textExtents(title)

		context:rectangle(MARGIN - 1, MARGIN - PADDING - 1,
			te.width + PADDING * 2 + 2, te.height + PADDING * 2 + 2)
		context:setSourceRGB(0, 0, 0)
		context:fill()

		context:rectangle(MARGIN, MARGIN - PADDING,
			te.width + PADDING * 2, te.height + PADDING * 2)
		context:setSourceRGB(255, 255, 255)
		context:stroke()

		context:moveTo(x, y + te.height)
		context:showText(title)

		y = y + te.height + PADDING
	end

	-- body
	context:rectangle(MARGIN - 1, y - 1,
		width - MARGIN * 2 + 2, height - y - MARGIN + 2)
	context:setSourceRGB(0, 0, 0)
	context:fill()

	context:rectangle(MARGIN, y,
		width - MARGIN * 2, height - y - MARGIN)
	context:setSourceRGB(255, 255, 255)
	context:stroke()

	context:translate(MARGIN, y)
	context:rectangle(0, 0, width - MARGIN * 2, height - y - MARGIN)
	context:clip()
end


return Tab
