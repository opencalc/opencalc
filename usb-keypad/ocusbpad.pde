/*
  OpenCalc USB Keypad Firmware

Copyright (C) 2011  Dean Blackketter <dean@opencalc.me>

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
 */

#define LED_PIN (11) 
#define KEY_ROWS (11)
#define KEY_COLUMNS (6)
#define KEY_ROW_0_PIN (12)
#define KEY_COLUMN_0_PIN (5)
#define ROLLOVER_KEYS (6)

#define MODIFIER_OFFSET (128)
#define MODIFIER_CTRL (MODIFIER_OFFSET + MODIFIERKEY_CTRL)
#define MODIFIER_ALT (MODIFIER_OFFSET + MODIFIERKEY_ALT)
#define MODIFIER_SHIFT (MODIFIER_OFFSET + MODIFIERKEY_SHIFT)

// Table for keypad
byte keymap[KEY_ROWS][KEY_COLUMNS] = 
	{
		{ KEY_A, KEY_B, KEY_C, KEY_D, KEY_E, KEY_F },  	  // F1 F2 F3 F4 F5 F6
		
		{ KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_F5, KEY_F6 },	  // Menu Keys
		
		{ KEY_G, KEY_H, KEY_I, KEY_J, KEY_K, KEY_L },             // Row 1 of math functions

		{ KEY_M, KEY_N, KEY_O, KEY_P, KEY_DOWN, KEY_UP },         // Second row of math functions, half the cursor keys

		{ KEY_Q, KEY_R, KEY_S, KEY_T, KEY_LEFT, KEY_RIGHT }, // CUT COPY PASTE EE and rest of cursor keys

		{ KEY_TAB, KEY_7, KEY_8, KEY_9, KEY_U, KEY_V },		  // SYM 7 8 9 ( )
		
		{ MODIFIER_CTRL, KEY_4, KEY_5, KEY_6, KEY_W, KEY_X },		  // ALPHA 4 5 6 * /
		
		{ MODIFIER_SHIFT, KEY_1, KEY_2, KEY_3, KEY_Y, KEY_Z },	          // SHIFT 1 2 3 - +
		
		{ KEY_ESC, KEY_0, KEY_PERIOD, KEY_SPACE, KEY_BACKSPACE, KEY_ENTER }		  // CLEAR 0 . +/-  BACKSPACE =
	};
	
byte keystate[KEY_ROWS][KEY_COLUMNS];
byte keystate_last[KEY_ROWS][KEY_COLUMNS];

void setup() {
  //   Teensy 2.0 has the LED on pin 11
  pinMode(LED_PIN, OUTPUT);

  // Initialize the column pins, which we'll be reading from
  for (int i = 0; i < KEY_COLUMNS; i++) {
		pinMode(KEY_COLUMN_0_PIN + i, INPUT_PULLUP);
  }
  
  // Initialize the rows, which we'll be toggling to output and low to read back the column
  for (int i = 0; i < KEY_ROWS; i++) {
		pinMode(KEY_ROW_0_PIN + i, INPUT);
  }
  
  // initialize the key state arrays
  for (int i = 0; i<KEY_ROWS; i++) {
  	for (int j = 0; j<KEY_COLUMNS; j++) {
  	keystate[i][j] = 0;
  	keystate_last[i][j] = 0;
    }
  }
}

void blink_led() { 
  // we sent a key so blink the LED
  digitalWrite(LED_PIN, HIGH);   // set the LED on
  delay(10);              // wait for a fraction
  digitalWrite(LED_PIN, LOW);    // set the LED off
}

void set_key(int key_index, int key_value) {
	switch (key_index) {
		case 0:
			Keyboard.set_key1(key_value);
			break;
		case 1:
			Keyboard.set_key2(key_value);
			break;
		case 2:
			Keyboard.set_key3(key_value);
			break;
		case 3:
			Keyboard.set_key4(key_value);
			break;
		case 4:
			Keyboard.set_key5(key_value);
			break;
		case 5:
			Keyboard.set_key6(key_value);
			break;
		default:
                        break;
	}			
}

void loop() {
  
  boolean keyactivity = false;
  
  // Scan each row, looking at each row to see if there are any buttons down
  for (int i = 0; i<KEY_ROWS; i++) {

		pinMode(KEY_ROW_0_PIN + i, OUTPUT);
  		digitalWrite(KEY_ROW_0_PIN + i, LOW);
  		
  		for (int j = 0; j<KEY_COLUMNS; j++) {
  			keystate[i][j] = !digitalRead(KEY_COLUMN_0_PIN + j);
  		}
  		
		pinMode(KEY_ROW_0_PIN + i, INPUT);		
  }
 
  // go through each key and check for changes
  for (int i = 0; i<KEY_ROWS; i++) {
 		for (int j = 0; j<KEY_COLUMNS; j++) {
			if (keystate[i][j] != keystate_last[i][j]) {
				keyactivity = true;
			}
		}
  }
  
  // if there's been any activity, send the keys
  if (keyactivity) {
    int rollover = 0;
    
    // clear out the key data that we'll send (this assumes that the position in the set_key table isn't important
  	for (int i = 0; i<ROLLOVER_KEYS; i++) {
  		set_key(i,0);
  	}

    uint8_t modifier = 0;
  	
	for (int i = 0; i<KEY_ROWS; i++) {
		for (int j = 0; j<KEY_COLUMNS; j++) {
			if (keystate[i][j]) {
				if (keymap[i][j] > MODIFIER_OFFSET) {
					modifier |= (keymap[i][j]-MODIFIER_OFFSET);
				} else {
					char key = keymap[i][j];
					if (
					
						(key >= KEY_A && key <= KEY_Z) ||
						(key >= KEY_1 && key <= KEY_0) ||
						(key == KEY_ENTER) ||
						(key == KEY_PERIOD) ||
						
					   0 ) {
						modifier |= MODIFIERKEY_ALT;
					}
				    set_key(rollover++, keymap[i][j]); 
			    }
			}
		}
	}

  	Keyboard.set_modifier(modifier);
  
  	Keyboard.send_now();
  	blink_led();
  }
 
  
  // copy the key state for the next time around
  for (int i = 0; i<KEY_ROWS; i++) {
 		for (int j = 0; j<KEY_COLUMNS; j++) {
 			keystate_last[i][j] = keystate[i][j];
 		}
  }
  
}
