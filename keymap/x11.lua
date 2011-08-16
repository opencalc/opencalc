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

--[[
  format:
	["key pressed"] = { "plain", "shifted", "alpha", "shifted alpha" }
--]]

return {

	["a"] = { "a", "A" },
	["b"] = { "b", "B" },
	["c"] = { "c", "C" },
	["d"] = { "d", "D" },
	["e"] = { "e", "E" },
	["f"] = { "f", "F" },

	F1 = { "<file>", false, false, false },
	F2 = { "<edit>", false, false, false },
	F3 = { "<view>", false, false, false },
	F4 = { "<function>", false, false, false },
	F5 = { "<app>", false, false, false },
	F6 = { "<setting>", false, false, false },

	["g"] = { "g", "G" },
	["h"] = { "h", "H" },
	["i"] = { "i", "I" },
	["j"] = { "j", "J" },
	["k"] = { "k", "K" },
	["l"] = { "l", "L" },

	["m"] = { "m", "M" },
	["n"] = { "n", "N" },
	["o"] = { "o", "O" },
	["p"] = { "p", "P" },  -- pi   0xcf80
	["Down"] = { "<down>", "<down>", "<down>", "<down>" },
	["Up"] = { "<up>", "<up>", "<up>", "<up>" },

	["q"] = { "q", "Q" },
	["r"] = { "r", "R" },
	["s"] = { "s", "S" },
	["t"] = { "t", "T" },
	["Right"] = { "<right>", "<right>", "<right>", "<right>" },
	["Left"] = { "<left>", "<left>", "<left>", "<left>" },

	["Tab"] = { "<sym>", "<sym>", "<sym>", "<sym>" },
	["7"] = { "7", "&", "7", "&" },
	["8"] = { "8", "~", "8", "~" },
	["9"] = { "9", "|", "9", "|" },
	["u"] = { "u", "U" },
	["v"] = { "v", "V" },

	["Control_L"] = { "<alpha>", "<alpha>", "<alpha>", "<alpha>" },
	["Control_R"] = { "<alpha>", "<alpha>", "<alpha>", "<alpha>" },
	["4"] = { "4", "$", "4", "$" },
	["5"] = { "5", ";", "5", ";" },
	["6"] = { "6", "^", "6", "^" },
	["w"] = { "w", "W" }, -- multiply c397
	["x"] = { "x", "X" }, -- divide c3b7

	["Shift_L"] = { "<shift>", "<shift>", "<shift>", "<shift>" },
	["Shift_R"] = { "<shift>", "<shift>", "<shift>", "<shift>" },
	["1"] = { "1", "_", "1", "_" },
	["2"] = { "2", "@", "2", "@" },
	["3"] = { "3", "#", "3", "#" },
	["y"] = { "y", "Y" },
	["z"] = { "z", "Z" },

	["Escape"] = { "<clear>", "<poweroff>", "<clear>", false },
	["0"] = { "0", "\"", "0", "\"" },
	["period"] = { ".", ",", ".", "," },
	["space"] = { "\194\177", " ", " ", " " }, --plusminus 0xc2b1
	["BackSpace"] = { "<delete>", "<undo>", "<delete>", "<delete>" },
	["Return"] = { "<enter>", "=", "<enter>", "<enter>" },

	-- keyboard compatibiliy
	["equal"] = { "=", "=", "=", "=" },
	["bracketleft"] = { "(", "(", "(", "(" },
	["bracketright"] = { ")", ")", ")", ")" },
	["apostrophe"] = { "\"", "'",  "\"", "'" },
	["comma"] = { ",", ",", ",", "," },
	
	-- for the hardware demo keypad, the alphabetic keys are sent as alt-letter
	-- so as to distinguish them from the standard qwerty keyboard
	
	["alt-a"] = { "<f1>", "<f7>", "a", "A" },
	["alt-b"] = { "<f2>", "<f8>", "b", "B" },
	["alt-c"] = { "<f3>", "<f9>", "c", "C" },
	["alt-d"] = { "<f4>", "<f10>", "d", "D" },
	["alt-e"] = { "<f5>", "<f11>", "e", "E" },
	["alt-f"] = { "<f6>", "<f12>", "f", "F" },
	["alt-g"] = { "sin(", "asin(", "g", "G" },
	["alt-h"] = { "cos(", "acos(", "h", "H" },
	["alt-i"] = { "tan(", "atan(", "i", "I" },
	["alt-j"] = { "ln(", "e(", "j", "J" },
	["alt-k"] = { "log10(", "^10,", "k", "K" },
	["alt-l"] = { "log2(", "^2,", "l", "L" },
	["alt-m"] = { "sqrt(", "sq(", "m", "M" },
	["alt-n"] = { "yx", "xrty", "n", "N" },
	["alt-o"] = { "1/", "!", "o", "O" },
	["alt-p"] = { "%", "\207\128", "p", "P" },  -- pi   0xcf80
	["alt-q"] = { "<cut>", "<m->", "q", "Q" },
	["alt-r"] = { "<copy>", "<m+>", "r", "R" },
	["alt-s"] = { "<paste>", "<mr>", "s", "S" },
	["alt-t"] = { "ee", ":", "t", "T" },
	["alt-u"] = { "(", "<", "u", "U" },
	["alt-v"] = { ")", ">", "v", "V" },
	["alt-w"] = { "\195\151", false, "w", "W" }, -- multiply c397
	["alt-x"] = { "\195\183", "\\", "x", "X" }, -- divide c3b7
	["alt-y"] = { "-", "\226\130\172", "y", "Y" }, -- euro 0xe282ac
	["alt-z"] = { "+", "'", "z", "Z" },

}
