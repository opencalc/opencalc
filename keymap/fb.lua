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
	30 = { "<f1>", "<f7>", "a", "A" },
	48 = { "<f2>", "<f8>", "b", "B" },
	46 = { "<f3>", "<f9>", "c", "C" },
	32 = { "<f4>", "<f10>", "d", "D" },
	18 = { "<f5>", "<f11>", "e", "E" },
	33 = { "<f6>", "<f12>", "f", "F" },

	59 = { "<file>", false, false, false },
	60 = { "<edit>", false, false, false },
	61 = { "<function>", false, false, false },
	62 = { "<view>", false, false, false },
	63 = { "<app>", false, false, false },
	64 = { "<setting>", false, false, false },

	34 = { "sin(", "asin(", "g", "G" },
	35 = { "cos(", "acos(", "h", "H" },
	23 = { "tan(", "atan(", "i", "I" },
	36 = { "ln(", "e(", "j", "J" },
	37 = { "log10(", "^10,", "k", "K" },
	38 = { "log2(", "^2,", "l", "L" },

	50 = { "sqrt(", "sq(", "m", "M" },
	49 = { "1/", "x3", "n", "N" },
	24 = { "yx", "xrty", "o", "O" },
	25 = { "%", "_", "p", "P" },
	108 = { "<down>", "<down>", "<down>", "<down>" },
	103 = { "<up>", "<up>", "<up>", "<up>" },

	74 = { "<cut>", "<m->", "<cut>", "<cut>" },
	78 = { "<copy>", "<m+>", "<copy>", "<copy>" },
	55 = { "<paste>", "<mr>", "<paste>", "<paste>" },
	16 = { "ee", "'", "q", "Q" },
	106 = { "<right>", "<right>", "<right>", "<right>" },
	105 = { "<left>", "<left>", "<left>", "<left>" },

	56 = { "<sym>", "<sym>", "<sym>", "<sym>" },
	8 = { "7", "&", "7", "&" },
	9 = { "8", "~", "8", "~" },
	10 = { "9", "|", "9", "|" },
	19 = { "(", "<", "r", "R" },
	31 = { ")", ">", "s", "S" },

	29 = { "<alpha>", "<alpha>", "<alpha>", "<alpha>" },
	5 = { "4", "#", "4", "#" },
	6 = { "5", ";", "5", ";" },
	7 = { "6", "^", "6", "^" },
	20 = { "\195\151", "$", "t", "T" }, -- multiply c397
	22 = { "\195\183", "\\", "u", "U" }, -- divide c3b7

	42 = { "<shift>", "<shift>", "<shift>", "<shift>" },
	2 = { "1", "!", "1", "!" },
	3 = { "2", "@", "2", "@" },
	4 = { "3", "#", "3", "#" },
	47 = { "-", "\226\130\172", "v", "V" }, -- euro 0xe282ac
	17 = { "+", "'", "w", "W" },

	1 = { "<clear>", "<poweroff>", "<clear>", false },
	11 = { "0", "\"", "0", "\"" },
	45 = { ".", ",", "x", "X" },
	21 = { "\194\177", ":", "y", "Y" }, --plusminus 0xc2b1
	44 = { "<delete>", "<undo>", "z", "Z" },
	28 = { "<enter>", "=", " ", " " },
}
