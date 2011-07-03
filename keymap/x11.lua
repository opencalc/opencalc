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

return {
	["8"] = { "8", "*" },
	["9"] = { "9", "(" },
	["0"] = { "0", ")" },
	a = { "a", "A" },
	b = { "b", "B" },
	c = { "c", "C" },
	d = { "d", "D" },
	e = { "e", "E" },
	f = { "f", "F" },
	g = { "g", "G" },
	h = { "h", "H" },
	i = { "i", "I" },
	j = { "j", "J" },
	k = { "k", "K" },
	l = { "l", "L" },
	m = { "m", "M" },
	n = { "n", "N" },
	o = { "o", "O" },
	p = { "p", "P" },
	q = { "q", "Q" },
	r = { "r", "R" },
	s = { "s", "S" },
	t = { "t", "T" },
	u = { "u", "U" },
	v = { "v", "V" },
	w = { "w", "W" },
	x = { "x", "X" },
	y = { "y", "Y" },
	z = { "z", "Z" },
	minus = { "-", "-" },
	equal = { "=", "+" },
	semicolon = { ":", ":" },
	slash = { "/", },
	space = { " ", " " },
	BackSpace = { "<delete>", "<delete>" },
	Control_L = {},
	Control_R = {},
	F1 = { "sin(", false },
	F2 = { "cos(", false },
	F3 = { "tan(", false },
	F4 = { "rand(", false },
	F5 = { "sum(", false },
	F12 = { "<view>", false },
	Return = { "=", "+" },
	Shift_L = { "<shift>", "<shift>" },
	Shift_R = { "<shift>", "<shift>" },
	Up = { "<move_up>", "<move_up>" },
	Down = { "<move_down>", "<move_down>" },
	Left = { "<move_left>", "<move_left>" },
	Right = { "<move_right>", "<move_right>" },
}
