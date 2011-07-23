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
	["a"] = { "<f1>", "<f7>", "a", "A" },
	["b"] = { "<f2>", "<f8>", "b", "B" },
	["c"] = { "<f3>", "<f9>", "c", "C" },
	["d"] = { "<f4>", "<f10>", "d", "D" },
	["e"] = { "<f5>", "<f11>", "e", "E" },
	["f"] = { "<f6>", "<f12>", "f", "F" },

	F1 = { "<file>", false, false, false },
	F2 = { "<edit>", false, false, false },
	F3 = { "<function>", false, false, false },
	F4 = { "<view>", false, false, false },
	F5 = { "<app>", false, false, false },
	F6 = { "<setting>", false, false, false },

	["g"] = { "sin(", "asin(", "g", "G" },
	["h"] = { "cos(", "acos(", "h", "H" },
	["i"] = { "tan(", "atan(", "i", "I" },
	["j"] = { "ln(", "e(", "j", "J" },
	["k"] = { "log10(", "^10,", "k", "K" },
	["l"] = { "log2(", "^2,", "l", "L" },

	["m"] = { "sqrt(", "sq(", "m", "M" },
	["n"] = { "1/", "x3", "n", "N" },
	["o"] = { "yx", "xrty", "o", "O" },
	["p"] = { "%", "_", "p", "P" },
	["Down"] = { "<down>", "<down>", "<down>", "<down>" },
	["Up"] = { "<up>", "<up>", "<up>", "<up>" },

	["KP_Subtract"] = { "<cut>", "<m->", "<cut>", "<cut>" },
	["KP_Add"] = { "<copy>", "<m+>", "<copy>", "<copy>" },
	["KP_Multiply"] = { "<paste>", "<mr>", "<paste>", "<paste>" },
	["q"] = { "ee", "'", "q", "Q" },
	["Right"] = { "<right>", "<right>", "<right>", "<right>" },
	["Left"] = { "<left>", "<left>", "<left>", "<left>" },

	["Alt_L"] = { "<sym>", "<sym>", "<sym>", "<sym>" },
	["Alt_R"] = { "<sym>", "<sym>", "<sym>", "<sym>" },
	["7"] = { "7", "&", "7", "&" },
	["8"] = { "8", "~", "8", "~" },
	["9"] = { "9", "|", "9", "|" },
	["r"] = { "(", "<", "r", "R" },
	["s"] = { ")", ">", "s", "S" },

	["Control_L"] = { "<alpha>", "<alpha>", "<alpha>", "<alpha>" },
	["Control_R"] = { "<alpha>", "<alpha>", "<alpha>", "<alpha>" },
	["4"] = { "4", "#", "4", "#" },
	["5"] = { "5", ";", "5", ";" },
	["6"] = { "6", "^", "6", "^" },
	["t"] = { "\195\151", "$", "t", "T" }, -- multiply c397
	["u"] = { "\195\183", "\\", "u", "U" }, -- divide c3b7

	["Shift_L"] = { "<shift>", "<shift>", "<shift>", "<shift>" },
	["Shift_R"] = { "<shift>", "<shift>", "<shift>", "<shift>" },
	["1"] = { "1", "!", "1", "!" },
	["2"] = { "2", "@", "2", "@" },
	["3"] = { "3", "#", "3", "#" },
	["v"] = { "-", "\226\130\172", "v", "V" }, -- euro 0xe282ac
	["w"] = { "+", "'", "w", "W" },

	["Escape"] = { "<clear>", "<poweroff>", "<clear>", false },
	["0"] = { "0", "\"", "0", "\"" },
	["x"] = { ".", ",", "x", "X" },
	["y"] = { "\194\177", ":", "y", "Y" }, --plusminus 0xc2b1
	["z"] = { "<delete>", "<undo>", "z", "Z" },
	["Return"] = { "<enter>", "=", " ", " " },

	-- keyboard compatibiliy
	["BackSpace"] = { "<delete>", "<delete>", "<delete>", "<delete>" },
	["space"] = { " ", " ", " ", " " },
	["equal"] = { "=", "=", "=", "=" },
	["bracketleft"] = { "(", "(", "(", "(" },
	["bracketright"] = { ")", ")", ")", ")" },
	["apostrophe"] = { "\"", "'",  "\"", "'" },
	["comma"] = { ",", ",", ",", "," },
	["period"] = { ".", ".", ".", "." },
}
