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

module(..., package.seeall)


Cell = {}


function Cell:new(sheet, row, col, text, val, f)
	obj = {
		_sheet = sheet,
		_row = row,
		_col = col,
		_text = tostring(text),
		_val = val,
		_f = f,
	}

	setmetatable(obj, self)
	self.__index = self
	return obj
end


function Cell:text()
	return self._text
end


function Cell:value()
	mp.clear_flags()
	return self:_value()
end


function Cell:_value()
	local set = self._sheet.set

	if self._f and self._uptodate ~= set then
		if self._visited == set then
			self._val = "!REF"
			self._uptodate = set
		else
			self._visited = set

			local ok, val = pcall(self._f, self._sheet, self)
			if ok then
				self._val = val or "!err"
				self._approx = mp.get_inexflag()
			else
				print("Error: " .. val)
				self._val = "!err"
				self._approx = nil
			end
			self._uptodate = set
		end
	end

	mp.set_inexflag(self._approx)
	return self._val, self._approx
end


function Cell:dump()
	print("[" .. self._row .. "," .. self._col .. "] " ..
		tostring(self:value()) .. " (" .. self._text .. ")")
end


return Cell
