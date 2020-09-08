//
//  KeyboardLayout.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/13/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public final class KeyboardLayout {

    static let perKeyGS65KeyMap: [[CGFloat]] = [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [0.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.50, 1],
        [0.75, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.25, 1],
        [1.25, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.75, 1],
        [1.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.50, 1, 1],
        [1.25, 1, 1, 4.75, 1, 1, 1, 1, 1, 1, 1]
    ]

    static let perKeyGS65KeyNames: [[String]] = [
        ["ESC", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "PRT", "DEL"],
        ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BACKSPACE", "HOME"],
        ["TAB", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", "\\", "PGUP"],
        ["CAPS", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "ENTER", "PGDN"],
        ["SHIFT", "Z", "X", "C", "V", "B", "N", "M", ", ", ".", "/", "SHIFT", "UP", "END"],
        ["CTRL", "WIN", "ALT", "SPACEBAR", "\\", "ALT", "FN", "CTRL", "LEFT", "DOWN", "RIGHT"]
    ]

    static let perKeyGS65KeyCodes: [[UInt8]] = [
        [0x18, 0x27, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x24, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x4b],
        [0x34, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x2c, 0x2d, 0x29, 0x49],
        [0x2a, 0x13, 0x19, 0x07, 0x14, 0x16, 0x1b, 0x17, 0x0b, 0x11, 0x12, 0x2e, 0x2f, 0x28, 0x4a],
        [0x38, 0x2a, 0x15, 0x06, 0x08, 0x09, 0x0a, 0x0c, 0x0d, 0x0e, 0x30, 0x33, 0x0b, 0x4d],
        [0xe0, 0x1c, 0x1a, 0x05, 0x18, 0x04, 0x10, 0x0f, 0x35, 0x36, 0x37, 0xe4, 0x51, 0x4c],
        [0x65, 0xe2, 0xe1, 0x2b, 0x32, 0xe5, 0xe6, 0xe3, 0x4f, 0x50, 0x4e]
    ]

    static let perKeyMap: [[CGFloat]] = [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1.25, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.75, 1, 1, 1, 1],
        [1.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.50, 1, 1, 1],
        [2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1],
        [3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1],
        [2, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ]

    static let perKeyNames: [[String]] = [
        ["ESC", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10",
         "F11", "F12", "PRT", "SCR", "BRK", "INS", "DEL", "PGUP", "PGDN"],
        ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BACKSPACE", "NUMLOCK", "/", "*", "-"],
        ["TAB", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", "\\", "7", "8", "9"],
        ["CAPS", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "ENTER", "4", "5", "6", "+"],
        ["SHIFT", "Z", "X", "C", "V", "B", "N", "M", ", ", ".", "/", "SHIFT", "UP", "1", "2", "3"],
        ["CTRL", "FN", "ALT", "SPACEBAR", "\\", "ALT", "WIN", "CTRL", "LEFT", "DOWN", "RIGHT", "0", ".", "ENTER"]
    ]

    static let perKeyCodes: [[UInt8]] = [
        [0x18, 0x27, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x24, 0x40, 0x41,
         0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x4b, 0x4a, 0x4d],
        [0x34, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x2c, 0x2d, 0x29, 0x52, 0x53, 0x54, 0x55],
        [0x2a, 0x13, 0x19, 0x07, 0x14, 0x16, 0x1b, 0x17, 0x0b, 0x11, 0x12, 0x2e, 0x2f, 0x28, 0x5e, 0x5f, 0x60],
        [0x38, 0x2a, 0x15, 0x06, 0x08, 0x09, 0x0a, 0x0c, 0x0d, 0x0e, 0x30, 0x33, 0x0b, 0x5b, 0x5c, 0x5d, 0x56],
        [0xe0, 0x1c, 0x1a, 0x05, 0x18, 0x04, 0x10, 0x0f, 0x35, 0x36, 0x37, 0xe4, 0x51, 0x58, 0x59, 0x5a],
        [0x65, 0xe6, 0xe1, 0x2b, 0x32, 0xe5, 0xe2, 0xe3, 0x4f, 0x50, 0x4e, 0x61, 0x62, 0x57]
    ]
}
