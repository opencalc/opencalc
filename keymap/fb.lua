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
	[2] = { "1", false },
	[3] = { "2", false },
	[4] = { "3", false },
	[5] = { "4", false },
	[6] = { "5", false },
	[7] = { "6", false },
	[8] = { "7", false },
	[9] = { "8", "*" },
	[10] = { "9", "(" },
	[11] = { "0", ")" },
	[30] = { "a", "A" },
	[48] = { "b", "B" },
	[46] = { "c", "C" },
	[32] = { "d", "D" },
	[18] = { "e", "E" },
	[33] = { "f", "F" },
	[34] = { "g", "G" },
	[35] = { "h", "H" },
	[23] = { "i", "I" },
	[36] = { "j", "J" },
	[37] = { "k", "K" },
	[38] = { "l", "L" },
	[50] = { "m", "M" },
	[49] = { "n", "N" },
	[24] = { "o", "O" },
	[25] = { "p", "P" },
	[16] = { "q", "Q" },
	[19] = { "r", "R" },
	[31] = { "s", "S" },
	[20] = { "t", "T" },
	[22] = { "u", "U" },
	[47] = { "v", "V" },
	[17] = { "w", "W" },
	[45] = { "x", "X" },
	[21] = { "y", "Y" },
	[44] = { "z", "Z" },
	[12] = { "-", "-" },
	[13] = { "=", "+" },
	[39] = { ":", ":" },
	[53] = { "/", },
	[57] = { " ", " " },
	[14] = { "<delete>", "<delete>" },
	[29] = {},
	[59] = { "sin(", false },
	[60] = { "cos(", false },
	[61] = { "tan(", false },
	[62] = { "rand(", false },
	[63] = { "sum(", false },
	[68] = { "<view>", false },
	[28] = { "=", "+" },
	[42] = { "<shift>", "<shift>" },
	[103] = { "<move_up>", "<move_up>" },
	[108] = { "<move_down>", "<move_down>" },
	[105] = { "<move_left>", "<move_left>" },
	[106] = { "<move_right>", "<move_right>" },
}
