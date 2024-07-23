characters = [
  { char: ' ', code: 32, shift: false },
  { char: '!', code: 33, shift: true },
  { char: '"', code: 34, shift: true },
  { char: '#', code: 35, shift: true },
  { char: '$', code: 36, shift: true },
  { char: '%', code: 37, shift: true },
  { char: '&', code: 38, shift: true },
  { char: "'", code: 39, shift: false },
  { char: '(', code: 40, shift: true },
  { char: ')', code: 41, shift: true },
  { char: '*', code: 42, shift: true },
  { char: '+', code: 43, shift: true },
  { char: ',', code: 44, shift: false },
  { char: '-', code: 45, shift: false },
  { char: '.', code: 46, shift: false },
  { char: '/', code: 47, shift: false },
  { char: '0', code: 48, shift: false },
  { char: '1', code: 49, shift: false },
  { char: '2', code: 50, shift: false },
  { char: '3', code: 51, shift: false },
  { char: '4', code: 52, shift: false },
  { char: '5', code: 53, shift: false },
  { char: '6', code: 54, shift: false },
  { char: '7', code: 55, shift: false },
  { char: '8', code: 56, shift: false },
  { char: '9', code: 57, shift: false },
  { char: ':', code: 58, shift: true },
  { char: ';', code: 59, shift: false },
  { char: '<', code: 60, shift: true },
  { char: '=', code: 61, shift: false },
  { char: '>', code: 62, shift: true },
  { char: '?', code: 63, shift: true },
  { char: '@', code: 64, shift: true },
  { char: 'A', code: 65, shift: true },
  { char: 'B', code: 66, shift: true },
  { char: 'C', code: 67, shift: true },
  { char: 'D', code: 68, shift: true },
  { char: 'E', code: 69, shift: true },
  { char: 'F', code: 70, shift: true },
  { char: 'G', code: 71, shift: true },
  { char: 'H', code: 72, shift: true },
  { char: 'I', code: 73, shift: true },
  { char: 'J', code: 74, shift: true },
  { char: 'K', code: 75, shift: true },
  { char: 'L', code: 76, shift: true },
  { char: 'M', code: 77, shift: true },
  { char: 'N', code: 78, shift: true },
  { char: 'O', code: 79, shift: true },
  { char: 'P', code: 80, shift: true },
  { char: 'Q', code: 81, shift: true },
  { char: 'R', code: 82, shift: true },
  { char: 'S', code: 83, shift: true },
  { char: 'T', code: 84, shift: true },
  { char: 'U', code: 85, shift: true },
  { char: 'V', code: 86, shift: true },
  { char: 'W', code: 87, shift: true },
  { char: 'X', code: 88, shift: true },
  { char: 'Y', code: 89, shift: true },
  { char: 'Z', code: 90, shift: true },
  { char: '[', code: 91, shift: false },
  { char: '\\', code: 92, shift: false },
  { char: ']', code: 93, shift: false },
  { char: '^', code: 94, shift: true },
  { char: '_', code: 95, shift: true },
  { char: '`', code: 96, shift: false },
  { char: 'a', code: 97, shift: false },
  { char: 'b', code: 98, shift: false },
  { char: 'c', code: 99, shift: false },
  { char: 'd', code: 100, shift: false },
  { char: 'e', code: 101, shift: false },
  { char: 'f', code: 102, shift: false },
  { char: 'g', code: 103, shift: false },
  { char: 'h', code: 104, shift: false },
  { char: 'i', code: 105, shift: false },
  { char: 'j', code: 106, shift: false },
  { char: 'k', code: 107, shift: false },
  { char: 'l', code: 108, shift: false },
  { char: 'm', code: 109, shift: false },
  { char: 'n', code: 110, shift: false },
  { char: 'o', code: 111, shift: false },
  { char: 'p', code: 112, shift: false },
  { char: 'q', code: 113, shift: false },
  { char: 'r', code: 114, shift: false },
  { char: 's', code: 115, shift: false },
  { char: 't', code: 116, shift: false },
  { char: 'u', code: 117, shift: false },
  { char: 'v', code: 118, shift: false },
  { char: 'w', code: 119, shift: false },
  { char: 'x', code: 120, shift: false },
  { char: 'y', code: 121, shift: false },
  { char: 'z', code: 122, shift: false },
  { char: '{', code: 123, shift: true },
  { char: '|', code: 124, shift: true },
  { char: '}', code: 125, shift: true },
  { char: '~', code: 126, shift: true },

  { char: 'Enter', code: 200, shift: false },
  { char: 'Backspace', code: 201, shift: false },
  { char: 'Delete', code: 202, shift: false },
  { char: 'Insert', code: 203, shift: false },
  { char: 'PageUp', code: 204, shift: false },
  { char: 'PageDown', code: 205, shift: false },
  { char: 'Home', code: 206, shift: false },
  { char: 'End', code: 207, shift: false },
  { char: 'F1', code: 208, shift: false },
  { char: 'F2', code: 209, shift: false },
  { char: 'F3', code: 210, shift: false },
  { char: 'F4', code: 211, shift: false },
  { char: 'F5', code: 212, shift: false },
  { char: 'F6', code: 213, shift: false },
  { char: 'F7', code: 214, shift: false },
  { char: 'F8', code: 215, shift: false },
  { char: 'F9', code: 216, shift: false },
  { char: 'F10', code: 217, shift: false },
  { char: 'F11', code: 218, shift: false },
  { char: 'F12', code: 219, shift: false },
  { char: 'F13', code: 220, shift: false },
  { char: 'Tab', code: 221, shift: false },
  { char: 'Escape', code: 222, shift: false },
  { char: 'Up', code: 223, shift: false },
  { char: 'Down', code: 224, shift: false },
  { char: 'Left', code: 225, shift: false },
  { char: 'Right', code: 226, shift: false },
  { char: 'CapsLock', code: 227, shift: false },
  { char: 'Shift', code: 228, shift: false },
  { char: 'Control', code: 229, shift: false },
  { char: 'Alt', code: 230, shift: false },
  { char: 'PrintScreen', code: 232, shift: false },
  { char: 'ScrollLock', code: 233, shift: false },
  { char: 'Pause', code: 234, shift: false },
  { char: 'NumLock', code: 235, shift: false },

  { char: 'Enter', code: 240, shift: true },
  { char: 'Backspace', code: 241, shift: true },
  { char: 'Delete', code: 242, shift: true },
  { char: 'Insert', code: 243, shift: true },
  { char: 'PageUp', code: 244, shift: true },
  { char: 'PageDown', code: 245, shift: true },
  { char: 'Home', code: 246, shift: true },
  { char: 'End', code: 247, shift: true },
  { char: 'F1', code: 248, shift: true },
  { char: 'F2', code: 249, shift: true },
  { char: 'F3', code: 250, shift: true },
  { char: 'F4', code: 251, shift: true },
  { char: 'F5', code: 252, shift: true },
  { char: 'F6', code: 253, shift: true },
  { char: 'F7', code: 254, shift: true },
  { char: 'F8', code: 255, shift: true },
  { char: 'F9', code: 256, shift: true },
  { char: 'F10', code: 257, shift: true },
  { char: 'F11', code: 258, shift: true },
  { char: 'F12', code: 259, shift: true },
  { char: 'F13', code: 260, shift: true },
  { char: 'Tab', code: 261, shift: true },
  { char: 'Escape', code: 262, shift: true },
  { char: 'Up', code: 263, shift: true },
  { char: 'Down', code: 264, shift: true },
  { char: 'Left', code: 265, shift: true },
  { char: 'Right', code: 266, shift: true },
  { char: 'CapsLock', code: 267, shift: true },
  { char: 'Shift', code: 268, shift: true },
  { char: 'Control', code: 269, shift: true },
  { char: 'Alt', code: 270, shift: true },
  { char: 'PrintScreen', code: 272, shift: true },
  { char: 'ScrollLock', code: 273, shift: true },
  { char: 'Pause', code: 274, shift: true },
  { char: 'NumLock', code: 275, shift: true }

]
start_code_point = 0x100000
offset = -1000
['', 'Control|', 'Alt|', 'Control|Alt|'].each do |com|
  offset += 1000
  characters.each do |char|
    mods = 'Command'
    mods += '|Shift' if char[:shift]
    code_point = start_code_point + char[:code] + offset

    utf_code = [code_point].pack('U*')
    utf8_bytes = utf_code.bytes.map { |b| format('\\x%02X', b) }.join

    puts "# {key = '#{char[:char]}', mods = '#{com}#{mods}', chars = '#{utf_code}'}, # #{"U+#{format('%06X', code_point)}: #{utf8_bytes}"}".gsub("'''",
                                                                                                                                                 "\"'\"")
  end
end
